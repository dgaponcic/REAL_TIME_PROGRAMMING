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
        {:ok, %{buffer: []}}
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
                IO.inspect("you have a buffer " <> Kernel.to_string(Kernel.length(state.buffer)))
                Sink.send_batch(state.buffer)
                []
            :error -> 
                state.buffer
            end

        {:noreply, %{buffer: buffer}}
    end


    def handle_cast({:add, record}, state) do
        buffer = [record | state.buffer]
        {:noreply, %{buffer: buffer}}
    end
end
