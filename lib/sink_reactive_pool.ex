defmodule Sink do
    use GenServer

    def start_link() do
        IO.puts("starting sink")
        {:ok, pid} = Mongo.start_link(url: "mongodb://localhost:27017/tweeter")
        GenServer.start_link(__MODULE__, %{pid: pid}, name: __MODULE__)
    end


    def init(state) do
        {:ok, %{records: [], mongo_pid: state.pid}}
    end

    def send_batch(records) do
        GenServer.cast(__MODULE__, {:send_batch, records})
    end


    def handle_cast({:send_batch, records}, state) do
        IO.inspect(Kernel.length(records))
        Mongo.insert_many(state.mongo_pid, "tweets", get_tweets(records))
        Mongo.insert_many(state.mongo_pid, "users", get_users(records))
        {:noreply, %{mongo_pid: state.mongo_pid}}
    end


    def get_tweets(records) do
        Enum.map(records, fn obj -> obj.tweet end)
    end


    def get_users(records) do
        Enum.map(records, fn obj -> obj.user end)
    end


    def check_health_state() do
        GenServer.call(__MODULE__, :heartbeat)
    end

    def check_health_state(true) do
        :ok
    end

    def check_health_state(false) do
        :error
    end

    def handle_call(:heartbeat, _from, state) do
        health_state = check_health_state(Enum.random(0..50) < 40)
        {:reply, health_state, state}
    end
end
