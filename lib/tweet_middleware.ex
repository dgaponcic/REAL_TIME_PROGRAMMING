defmodule TweetMiddleware do
    use GenServer 

    def start_link() do
        IO.puts("starting tweet middleware")
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__, )
    end


    def init(_state) do 
        {:ok, %{}}
    end

    def route(tweet) do
        GenServer.cast(__MODULE__, {:route, tweet})
    end


    defp retweeted(nil) do

    end

    defp retweeted(tweet) do
        Router.route(tweet)
    end
    

    def handle_cast({:route, tweet}, _state) do
        {:ok, tweet} = Poison.decode(tweet.data)
        tweet = tweet["message"]["tweet"]
        Router.route(tweet)
        retweeted(tweet["retweeted_status"])
        {:noreply, %{}}
    end

    def get_obj(record) do
        {:ok, tweet} = Poison.decode(record["tweet"])
        tweet = tweet["message"]["tweet"]
        user = tweet["user"]
        tweet = Map.update!(tweet, "user", fn user -> user["id"] end)

        %{
            tweet: %{
                engagement: record["engagement"],
                sentiment: record["sentiment"],
                tweet: tweet
            },
            user: user
        }
    end
end
