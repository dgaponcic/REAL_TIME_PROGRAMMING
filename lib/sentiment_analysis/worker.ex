defmodule SentimentAnalysis.Worker do
    use GenServer

    def start_link(index) do
        IO.puts("starting worker sentiment #{index}")
        
        {:ok, pid} = GenServer.start_link(__MODULE__, %{index: index}, [name: :"WorkerSentiment#{index}"])
        Registry.register(Registry.ViaTest, "WorkerSentiment" <> Integer.to_string(index), pid)
        {:ok, pid}
    end


    defp get_score(words) do
        words
        |> Enum.reduce(0, fn word, acc -> Sentiments.get_value(word) + acc end)
        |> Kernel./(length(words))
    end

    def get_words(tweet) do
        punctuation = [",", ".", ":", "?", "!"]
        tweet["message"]["tweet"]["text"]
        |> String.replace(punctuation, "")
        |> String.split(" ", trim: true)
    end


    defp print(tweet, index) do
        {:ok, tweet} = Poison.decode(tweet)
        
        score = tweet
        |> get_words()
        |> get_score()

        IO.inspect("Sentiment score: " <> Float.to_string(score))
        Router.task_done({index, "WorkerSentiment"})
    end


    def handle_tweet(tweet) do
        GenServer.cast(__MODULE__, {:print, tweet})
    end


    def init(state) do
        {:ok, state}
    end


    def handle_cast({:print, tweet}, state) do
        :timer.sleep(Enum.random(0..50))
        print(tweet, state.index)

        {:noreply, state}
    end
end
