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


    def update_nb_per_interval(true, true) do
        GenServer.cast(__MODULE__, {:update, -10})
    end

    def update_nb_per_interval(true, false) do
        GenServer.cast(__MODULE__, {:update, 10})
    end

    def update_nb_per_interval(_, _) do
        
    end
    

    def new_measurement(nb_records, time) do
        update_nb_per_interval(time > 20, nb_records > 300)
    end


    def handle_cast({:update, val}, state) do
        records_per_interval = state.records_per_interval + val
        Buffer.set_records_per_interval(records_per_interval)
        {:noreply, %{records_per_interval: records_per_interval}}
    end
end
