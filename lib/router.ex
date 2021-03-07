defmodule Router do
    use GenServer

    def start_link() do
        IO.puts("starting router")
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end


    def init(_state) do
        active_sentiment_tasks = def_active(&SentimentAnalysis.Supervisor.get_nb_children/0, :sentiment)
        active_engagement_tasks = def_active(&EngagementAnalysis.Supervisor.get_nb_children/0, :engagement)

        {:ok, 
            %{
                sentiment: %{active: active_sentiment_tasks, total: SentimentAnalysis.Supervisor.get_nb_children()},
                engagement: %{active: active_engagement_tasks, total: EngagementAnalysis.Supervisor.get_nb_children()}
            }
        }
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


    defp get_worker_name(type, index) do
        String.to_atom(Atom.to_string(type) <> "Worker" <> Integer.to_string(index))
    end


    defp define_active_tasks(range, type) do
        Enum.reduce(range, [], fn index, acc -> 
            acc ++ [
                %{name: get_worker_name(type, index), index: index, val: 0}
            ]
        end)
    end

    
    defp def_active(get_children, some_string) do
        range = 0..get_children.() - 1
        define_active_tasks(range, some_string)
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


    defp update_value_tasks(tasks, index, worker, fun) do
        List.update_at(
            tasks, 
            index,
            &(%{name: worker.name, index: worker.index, val: fun.(&1.val)})
        )
    end


    defp choose_worker(active_tasks) do
        Enum.min_by(active_tasks, fn worker -> worker.val end)
    end


    defp task_done(:sentiment, index, state) do
        worker = Enum.at(state.sentiment.active, index)
        active_tasks = update_value_tasks(state.sentiment.active, index, worker, &(&1 - 1))

        %{
            sentiment: %{active: active_tasks, total: state.sentiment.total},
            engagement: state.engagement
        }
    end


    defp task_done(:engagement, index, state) do
        worker = Enum.at(state.engagement.active, index)
        active_tasks = update_value_tasks(state.engagement.active, index, worker, &(&1 - 1))
        
        %{
            sentiment: state.sentiment,
            engagement: %{active: active_tasks, total: state.engagement.total}
        }
    end


    defp delegate_task(active_tasks, tweet, id) do
        worker = choose_worker(active_tasks)
        index = worker.index
        active_tasks = update_value_tasks(active_tasks, index, worker, &(&1 + 1))
        GenServer.cast(worker.name, {:compute, {id, tweet}})
        active_tasks
    end


    defp route_worker(type, state, get_nb_children, tweet, id) do
        active_tasks = delegate_task(state.active, tweet, id)
        new_workers = get_nb_children.()
        old_workers = state.total
        active_tasks = update_active_tasks(old_workers, new_workers, active_tasks, type)

        {active_tasks, new_workers}
    end

    def handle_cast({:task_done, {type, index}}, state) do
        new_state = task_done(type, index, state)
        {:noreply, new_state}
    end
    

    def handle_cast({:route, {id, tweet}}, state) do
        sent_nb_children = &SentimentAnalysis.Supervisor.get_nb_children/0
        {active_sent_tasks, new_sent_workers} = route_worker(:sentiment, state.sentiment, sent_nb_children, tweet, id)
        eng_nb_children = &EngagementAnalysis.Supervisor.get_nb_children/0
        {active_eng_tasks, new_eng_workers} = route_worker(:engagement, state.engagement, eng_nb_children, tweet, id)

        {:noreply, 
            %{
                sentiment: %{active: active_sent_tasks, total: new_sent_workers},
                engagement: %{active: active_eng_tasks, total: new_eng_workers}
            }
        }
    end
end
