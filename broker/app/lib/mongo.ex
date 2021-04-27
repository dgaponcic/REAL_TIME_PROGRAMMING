defmodule MongoConnection do
    use GenServer

    def start_link() do
        IO.puts("starting persistant sender")
        {:ok, pid} = Mongo.start_link(url: "mongodb://mongo_broker:27017/messages")
        GenServer.start_link(__MODULE__, %{pid: pid}, name: __MODULE__)
    end


    def init(state) do
        {:ok, state}
    end


    def insert(msg) do
        GenServer.call(__MODULE__, {:insert, msg})
    end


    def delete(id) do
        GenServer.cast(__MODULE__, {:delete, id})
    end


    def get(id) do
        GenServer.call(__MODULE__, {:get, id})
    end 


    def handle_cast({:delete, id}, state) do
        res = Mongo.delete_one(state.pid, "messages", %{_id: id})
        {:noreply, state}
    end


    def handle_call({:insert, msg}, _from, state) do
        {:ok, %{acknowledged: true, inserted_id: id}} = Mongo.insert_one(state.pid, "messages", msg)
        {:reply, id, state}
    end


    def handle_call({:get, id}, _from, state) do
        msg = Mongo.find_one(state.pid, "messages", %{_id: id}, [projection: %{"_id" => 0}])
        {:reply, msg, state}
    end  
end
