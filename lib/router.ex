defmodule Router do
    use GenServer

    def start_link() do
        IO.puts("starting router")
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end


    def route(tweet) do
        TopHashtags.rcv_data(tweet.data)
        id = UUID.uuid1()
        Aggregator.add_tweet(id, tweet.data)

        GenServer.cast(__MODULE__, {:route, {id, tweet.data}})
    end


    def task_done(index) do
        GenServer.cast(__MODULE__, {:task_done, index})
    end


    defp define_active_tasks(range, type) do
        res = Enum.reduce(range, [], fn index, acc -> 
            acc ++ [
                %{
                    name: String.to_atom(type <> Integer.to_string(index)), 
                    index: index,
                    val: 0
                }
            ]
        end)
    end

    
    def init(_state) do
        range_sentiment = 0..SentimentAnalysis.Supervisor.get_nb_children() - 1
        active_sentiment_tasks = define_active_tasks(range_sentiment, "WorkerSentiment")

        range_engagement = 0..EngagementAnalysis.Supervisor.get_nb_children() - 1
        active_engagement_tasks = define_active_tasks(range_sentiment, "WorkerEngagement")
        {:ok, 
            %{
                active_sentiment_tasks: active_sentiment_tasks, 
                total_sentiment_workers: SentimentAnalysis.Supervisor.get_nb_children(),
                active_engagement_tasks: active_engagement_tasks, 
                total_engagement_workers: EngagementAnalysis.Supervisor.get_nb_children()
            }
        }
    end


    defp update_active_tasks(true, active_tasks, diff, type) do
        init_index = length(active_tasks)
        range = init_index..init_index + diff - 1
        new_workers = define_active_tasks(range, type)

        active_tasks ++ new_workers
    end


    defp update_active_tasks(false, active_tasks, diff, _type) do
        Enum.drop(active_tasks, -diff)
    end


    defp update_active_tasks(old_workers, new_workers, active_tasks, type) do
        diff = new_workers - old_workers
        update_active_tasks(new_workers > old_workers, active_tasks, abs(diff), type)
    end


    def update_value_tasks(tasks, index, worker, fun) do
        List.update_at(
            tasks, 
            index,
            &(%{name: worker.name, index: worker.index, val: fun.(&1.val)})
        )
    end


    defp choose_worker(active_tasks) do
        Enum.min_by(active_tasks, fn worker -> worker.val end)
    end


    def task_done("WorkerSentiment", index, state) do
        worker = Enum.at(state.active_sentiment_tasks, index)
        active_tasks = update_value_tasks(state.active_sentiment_tasks, index, worker, &(&1 - 1))
        
        %{
            active_sentiment_tasks: active_tasks, 
            total_sentiment_workers: state.total_sentiment_workers,
            active_engagement_tasks: state.active_engagement_tasks, 
            total_engagement_workers: state.total_engagement_workers
        }
    end


    def task_done("WorkerEngagement", index, state) do
        worker = Enum.at(state.active_engagement_tasks, index)
        active_tasks = update_value_tasks(state.active_engagement_tasks, index, worker, &(&1 - 1))
        
        %{
            active_sentiment_tasks: state.active_sentiment_tasks, 
            total_sentiment_workers: state.total_sentiment_workers,
            active_engagement_tasks: active_tasks, 
            total_engagement_workers: state.total_engagement_workers
        }
    end


    def handle_cast({:task_done, {index, type}}, state) do
        new_state = task_done(type, index, state)
        {:noreply, new_state}
    end


    def delegate_task(active_tasks, tweet, id) do
        worker = choose_worker(active_tasks)

        index = worker.index
        active_tasks = update_value_tasks(active_tasks, index, worker, &(&1 + 1))
        GenServer.cast(worker.name, {:compute, {id, tweet}})
        active_tasks
    end


    def route2sentiment_worker(state, tweet, id) do
        active_tasks = delegate_task(state.active_sentiment_tasks, tweet, id)
        new_workers = SentimentAnalysis.Supervisor.get_nb_children()
        old_workers = state.total_sentiment_workers
        active_tasks = update_active_tasks(old_workers, new_workers, active_tasks, "WorkerSentiment")

        {active_tasks, new_workers}
    end


    def route2engagement_worker(state, tweet, id) do
        active_tasks = delegate_task(state.active_engagement_tasks, tweet, id)
        new_workers = EngagementAnalysis.Supervisor.get_nb_children()
        old_workers = state.total_engagement_workers
        active_tasks = update_active_tasks(old_workers, new_workers, active_tasks, "WorkerEngagement")

        {active_tasks, new_workers}
    end


    def handle_cast({:route, {id, tweet}}, state) do
        {active_sentiment_tasks, new_sentiment_workers} = route2sentiment_worker(state, tweet, id)
        {active_engagement_tasks, new_engagement_workers} = route2engagement_worker(state, tweet, id)

        {:noreply,  
            %{
                active_sentiment_tasks: active_sentiment_tasks, 
                total_sentiment_workers: new_sentiment_workers,
                active_engagement_tasks: active_engagement_tasks,
                total_engagement_workers: new_engagement_workers
            }
        }
    end
end
