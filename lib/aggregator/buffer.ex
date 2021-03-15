defmodule Buffer do
    use GenServer

    def start_link() do
        IO.inspect("starting buffer")
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end


    def add_record(record) do
        GenServer.cast(__MODULE__, {:add, record})
    end


    def init(_) do
        schedule_free_buffer()
        {:ok, %{buffer: [], records_per_interval: 0}}
    end


    def set_records_per_interval(records_per_interval) do
        GenServer.cast(__MODULE__, {:set_nb_records, records_per_interval})
    end

    def handle_cast({:set_nb_records, records_per_interval}, state) do
        {:noreply, %{buffer: state.buffer, records_per_interval: records_per_interval}}
    end


    def schedule_free_buffer() do
        interval = 1000
        Process.send_after(self(), :free_buffer, interval)
    end


    def handle_info(:free_buffer, state) do
        schedule_free_buffer()
        health = HealthState.get_health()

        buffer = case health do
            :ok ->
                TODO
                IO.inspect("you have a buffer " <> Kernel.to_string(Kernel.length(state.buffer)))
                to_send = Enum.take(state.buffer, -state.records_per_interval)
                Sink.send_batch(to_send)
                Enum.drop(state.buffer, -state.records_per_interval)
            :error -> 
                state.buffer
            end

        {:noreply, %{buffer: buffer, records_per_interval: state.records_per_interval}}
    end


    def handle_cast({:add, record}, state) do
        buffer = [record | state.buffer]
        {:noreply, %{buffer: buffer, records_per_interval: state.records_per_interval}}
    end
end
