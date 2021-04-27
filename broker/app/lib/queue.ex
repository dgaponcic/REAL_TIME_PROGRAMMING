defmodule Queue do
    use GenServer

    def start_link() do
        IO.puts("starting persistant sender")
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end


    def init(_state) do
        state = %{store: :queue.new}
        {:ok, state}
    end
    

    def add(record, clients, ttl) do
        GenServer.cast(__MODULE__, {:add, record, clients, ttl})
    end


    def get() do
        GenServer.call(__MODULE__, :get)
    end


    def len() do
        GenServer.call(__MODULE__, :len)
    end


    def handle_call(:len, _from, state) do
        {:reply, :queue.len(state.store), state}
    end


    def handle_cast({:add, record, clients, ttl}, state) do 
        store = :queue.in({record, clients, ttl}, state.store)     
        {:noreply, %{store: store}}
    end


    def handle_call(:get, _from, state) do   
        {val, queue} = case :queue.out(state.store) do
            {{:value, head}, queue} -> {head, queue}
            {:empty, queue} -> {nil, queue}
        end

        {:reply, val, %{store: queue}}
    end
end
