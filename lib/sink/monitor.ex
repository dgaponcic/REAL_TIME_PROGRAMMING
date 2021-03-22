defmodule Monitor do
    use GenServer

    def start_link() do
        IO.inspect("starting monitor")
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def init(_) do
        Buffer.set_records_per_interval(100)
        {:ok, %{records_per_interval: 100}}
    end


    def is_down() do
        GenServer.cast(__MODULE__, :down)
    end

    
    def is_up() do
        GenServer.cast(__MODULE__, :up)
    end


    def new_measurement(nb_records, time) do
        case {time > 30, nb_records > 150} do
            {true, true} -> GenServer.cast(__MODULE__, {:update, -10})
            {true, false} -> GenServer.cast(__MODULE__, {:update, 10})
            {_, _} -> 
        end
    end


    def handle_cast(:down, state) do
        Buffer.set_records_per_interval(0)
        {:noreply, %{records_per_interval: 0}}
    end


    def handle_cast(:up, state) do
        Buffer.set_records_per_interval(100)
        {:noreply, %{records_per_interval: 100}}
    end


    def handle_cast({:update, val}, state) do
        records_per_interval = state.records_per_interval + val
        Buffer.set_records_per_interval(records_per_interval)
        {:noreply, %{records_per_interval: records_per_interval}}
    end
end
