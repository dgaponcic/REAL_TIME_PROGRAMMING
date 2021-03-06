defmodule EngagementAnalysis.Worker do
    use GenServer

    def start_link(index) do
        IO.puts("starting worker engament #{index}")
        
        {:ok, pid} = GenServer.start_link(__MODULE__, %{index: index}, [name: :"WorkerEngagement#{index}"])
        Registry.register(Registry.ViaTest, "WorkerEngagement" <> Integer.to_string(index), pid)
        {:ok, pid}
    end


    def init(state) do
        {:ok, state}
    end

    defp calculate_score(0, favourites, retweets) do
        favourites + retweets
    end

    defp calculate_score(followers, favourites, retweets) do
        (favourites + retweets) / followers
    end

    defp compute(tweet, id, index) do
        {:ok, tweet} = Poison.decode(tweet)

        followers = tweet["message"]["tweet"]["user"]["followers_count"]
        favourites = tweet["message"]["tweet"]["user"]["favourites_count"]
        retweets = tweet["message"]["tweet"]["retweet_count"]
        score = calculate_score(followers, favourites, retweets)
        
        # IO.inspect("Engagement score: " <> Float.to_string(score))
        Aggregator.add_engagement(id, score)
        Router.task_done({index, "WorkerEngagement"})
    end


    def handle_cast({:compute, {id, tweet}}, state) do
        # to check least connected routing
        :timer.sleep(Enum.random(0..50))
        compute(tweet, id, state.index)

        {:noreply, state}
    end
end
