defmodule AutoScaler do
    use GenServer 

    def start_link() do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def rcv_data(tweet) do
        GenServer.cast(__MODULE__, {:count, tweet})
    end

    def init(_state) do
        schedule_work()
        {:ok, %{counter: 0}}
    end


    def scale(true, count) do
        WorkerSupervisor.start_child(count)
    end


    def scale(false, count) do
        WorkerSupervisor.stop_child(count)
    end


    def handle_info(:work, state) do
        
        desired_nb_workers = 1 + div(state.counter, 15)
        IO.inspect(desired_nb_workers)
        actual_nb_workers = WorkerSupervisor.get_nb_children()
        IO.inspect(actual_nb_workers)
        scale(desired_nb_workers > actual_nb_workers, abs(desired_nb_workers - actual_nb_workers))

        schedule_work()
        {:noreply, %{counter: 0}}
      end

      
    def handle_cast({:count, _}, state) do
        {:noreply, %{counter: state.counter + 1}}
    end

    defp schedule_work() do
        interval = 1000
        Process.send_after(self(), :work, interval)
    end
end
