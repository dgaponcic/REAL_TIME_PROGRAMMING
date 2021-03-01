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

    defp print(tweet, index) do
        {:ok, tweet} = Poison.decode(tweet)

        followers = tweet["message"]["tweet"]["user"]["followers_count"]
        favourites = tweet["message"]["tweet"]["user"]["favourites_count"]
        retweets = tweet["message"]["tweet"]["retweet_count"]
        score = calculate_score(followers, favourites, retweets)
        IO.inspect("Engagement score: " <> Float.to_string(score))
        Router.task_done({index, "WorkerEngagement"})
    end


    def handle_cast({:print, tweet}, state) do
        :timer.sleep(Enum.random(0..50))
        print(tweet, state.index)

        {:noreply, state}
    end
end
