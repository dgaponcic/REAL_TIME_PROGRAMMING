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
        {:ok, %{buffer: []}}
    end

    def free_buffer() do
        GenServer.cast(__MODULE__, :free)
        
    end


    def handle_cast({:add, record}, state) do
        buffer = [record | state.buffer]
        {:noreply, %{buffer: buffer}}
    end

    def handle_cast(:free, state) do
        IO.inspect("you have a buffer " <> Kernel.to_string(Kernel.length(state.buffer)))
        Enum.each(state.buffer, fn record -> Sink.rcv_record(record) end)
        {:noreply, %{buffer: []}}
    end
end