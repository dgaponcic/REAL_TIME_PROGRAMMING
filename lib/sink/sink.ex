defmodule Sink do
    use GenServer

    def start_link() do
        IO.puts("starting sink")
        {:ok, pid} = Mongo.start_link(url: "mongodb://localhost:27017/tweeter")
        GenServer.start_link(__MODULE__, %{mongo_pid: pid}, name: __MODULE__)
    end


    def init(state) do
        {:ok, state}
    end

    def send_batch(records) do
        GenServer.cast(__MODULE__, {:send_batch, records})
    end

    def insert_many({mongo_pid, records}) do
        Mongo.insert_many(mongo_pid, "tweets", get_tweets(records))
        Mongo.insert_many(mongo_pid, "users", get_users(records))
    end

    def time(f, args) do
        init_time = :os.system_time(:millisecond)
        response = f.(args)
        exec_time = :os.system_time(:millisecond) - init_time
        {exec_time, response}
    end

    def handle_cast({:send_batch, records}, state) do
        nb_records = IO.inspect(Kernel.length(records))
        {exec_time, _response} = time(&insert_many/1, {state.mongo_pid, records})
        Monitor.new_measurement(nb_records, exec_time)
        
        {:noreply, state}
    end


    def get_tweets(records) do
        Enum.map(records, fn obj -> obj.tweet end)
    end


    def get_users(records) do
        Enum.map(records, fn obj -> obj.user end)
    end


    def check_health_state() do
        GenServer.call(__MODULE__, :health_check)
    end

    def check_health_state(true) do
        :ok
    end

    def check_health_state(false) do
        :error
    end

    def handle_call(:health_check, _from, state) do
        health_state = check_health_state(Enum.random(0..50) < 45)
        {:reply, health_state, state}
    end
end
