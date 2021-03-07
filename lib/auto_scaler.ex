defmodule AutoScaler do
    use GenServer 

    def start_link() do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end


    def rcv_data() do
        GenServer.cast(__MODULE__, :count)
    end


    def scale(:sentiment, true, count) do
        SentimentAnalysis.Supervisor.start_child(count)
    end


    def scale(:sentiment, false, count) do
        SentimentAnalysis.Supervisor.stop_child(count)
    end

    def scale(:engagement, true, count) do
        EngagementAnalysis.Supervisor.start_child(count)
    end


    def scale(:engagement, false, count) do
        EngagementAnalysis.Supervisor.stop_child(count)
    end


    def init(_state) do
        schedule_work()
        {:ok, %{counter: 0}}
    end

    
    def handle_info(:work, state) do
        desired_nb_workers = 1 + div(state.counter, 15)
        actual_nb_workers = SentimentAnalysis.Supervisor.get_nb_children()

        diff = abs(desired_nb_workers - actual_nb_workers)
        scale(:sentiment, desired_nb_workers > actual_nb_workers, diff)
        scale(:engagement, desired_nb_workers > actual_nb_workers, diff)

        schedule_work()
        {:noreply, %{counter: 0}}
      end

      
    def handle_cast(:count, state) do
        {:noreply, %{counter: state.counter + 1}}
    end


    defp schedule_work() do
        interval = 1000
        Process.send_after(self(), :work, interval)
    end
end
