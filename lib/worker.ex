defmodule Worker do
    use GenServer

    def start_link(index) do
        IO.puts("starting worker#{index}")
        GenServer.start_link(__MODULE__, :ok, [name: :"Worker#{index}"])
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
        IO.puts(tweet)
    end

    @impl true
    def handle_cast({:print, tweet}, _) do
        {:noreply, print(tweet, tweet =~ "panic")}
    end

end
