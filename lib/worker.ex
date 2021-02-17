defmodule Worker do
    use GenServer

    def start_link(index) do
        IO.puts("starting worker#{index}")
        
        {:ok, pid} = GenServer.start_link(__MODULE__, :ok, [name: :"Worker#{index}"])
        Registry.register(Registry.ViaTest, "Worker" <> Integer.to_string(index), pid)
        {:ok, pid}
    end

    def handle_tweet(tweet) do
        GenServer.cast(__MODULE__, {:print, tweet})
    end


    @impl true
    def init(:ok) do
        {:ok, %{}}
    end

    def print(tweet, true) do
        IO.inspect("panic")
        Process.exit(self(), :kill)
    end

    def print(tweet, false) do
        {:ok, tweet} = Poison.decode(tweet)
        hashtags = tweet["message"]["tweet"]["entities"]["hashtags"]
        
        words = tweet["message"]["tweet"]["text"]
        |> String.split(" ", trim: true)

        score = words
        |> Enum.reduce(0, fn word, acc -> Sentiments.get_value(word) + acc end)
        |> Kernel./(length(words))
        IO.inspect(score)
        
    end

    @impl true
    def handle_cast({:print, tweet}, _) do
        :timer.sleep(Enum.random(0..50))
        {:noreply, print(tweet, tweet =~ "panic")}
    end

end
