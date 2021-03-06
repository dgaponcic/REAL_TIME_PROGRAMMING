defmodule Sink do
    use GenServer

    def start_link() do
        IO.puts("starting sink")
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end


    def init(_state) do
        timer = Process.send_after(self(), :send_batch, 1000)
        {:ok, %{records: [], timer: timer}}
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
        {:noreply, %{records: records, timer: state.timer}}
    end


    def handle_info(:send_batch, state) do
        # send record to db
        IO.inspect(Kernel.length(state.records))
        timer = Process.send_after(self(), :send_batch, 1000)
        {:noreply, %{records: [], timer: timer}}
    end

end