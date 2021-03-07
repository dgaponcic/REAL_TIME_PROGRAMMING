defmodule MongoConn do
    use GenServer 

    def start_link(url) do
        {:ok, pid} = Mongo.start_link(url: url)
        GenServer.start_link(__MODULE__, %{pid: pid}, name: __MODULE__)
    end


    def init(state) do
        {:ok, %{pid: state. pid}}
    end


    def add(collection, data) do
        GenServer.cast(__MODULE__, {:add, {collection, data}})
    end

    
    def add_many(collection, data) do
        GenServer.cast(__MODULE__, {:add_many, {collection, data}})
    end


    def handle_cast({:add, {collection, data}}, state) do
        Mongo.insert_one(state.pid, collection, data)
        {:noreply, state}
    end

    
    def handle_cast({:add_many, {collection, data}}, state) do
        Mongo.insert_many(state.pid, collection, data)
        {:noreply, state}
    end
end
