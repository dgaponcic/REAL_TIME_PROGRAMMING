defmodule QueueReleaser do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__, %{})
    end

    def init(state) do
        schedule_work()
        {:ok, state}
    end

    def send({:empty, {[], []}}) do
        
    end

    def send({id, clients, ttl}) do
        record = MongoConnection.get(id)
        Sender.send_persistent(record, clients, id, ttl)
    end

    def handle_info(:release, state) do
        if Queue.len() > 0 do
            {id, clients, ttl} = Queue.get()
            record = MongoConnection.get(id)
            msg = %TypedMsgs.DataMsg{topic: record["topic"], content: record["content"], is_persistent: true}
            Sender.send_persistent(msg, clients, id, ttl)
            schedule_work()
        else
            schedule_work()
        end

        {:noreply, state}
    end

    defp schedule_work() do
        Process.send_after(self(), :release, 10)

    end
end