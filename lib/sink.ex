defmodule Sink do
    use GenServer

    def start_link() do
        IO.puts("starting sink")
        {:ok, pid} = Mongo.start_link(url: "mongodb://localhost:27017/tweeter")
        GenServer.start_link(__MODULE__, %{pid: pid}, name: __MODULE__)
    end


    def init(state) do
        timer = Process.send_after(self(), :send_batch, 1000)
        {:ok, %{records: [], timer: timer, mongo_pid: state.pid}}
    end

    def rcv_record(record) do
        GenServer.cast(__MODULE__, {:add_record, record})
    end


    def send(false) do
    end


    def send(_time_until) do
        Process.send(self(), :send_batch, [])
    end


    def update_state(true, records, timer) do
        time_until = Process.cancel_timer(timer, [])
        send(time_until)
    end


    def update_state(false, records, timer) do
    end


    def handle_cast({:add_record, record}, state) do
        records = [record | state.records]
        nb_records = Kernel.length(records)
        update_state(nb_records >= 100, records, state.timer)
        {:noreply, %{records: records, timer: state.timer, mongo_pid: state.mongo_pid}}
    end


    def get_tweets(records) do
        Enum.map(records, fn obj -> obj.tweet end)
    end


    def get_users(records) do
        Enum.map(records, fn obj -> obj.user end)
    end


    def handle_info(:send_batch, state) do
        IO.inspect(Kernel.length(state.records))
        Mongo.insert_many(state.mongo_pid, "tweets", get_tweets(state.records))
        Mongo.insert_many(state.mongo_pid, "users", get_users(state.records))
        timer = Process.send_after(self(), :send_batch, 1000)
        {:noreply, %{records: [], timer: timer, mongo_pid: state.mongo_pid}}
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