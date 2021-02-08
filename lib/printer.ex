defmodule Printer do
    use GenServer

    def start(index) do
        GenServer.start_link(__MODULE__, :ok, name: {:global, index})
    end

    def print(tweet) do
        GenServer.cast(__MODULE__, {:print, tweet})
    end


    @impl true
    def init(:ok) do
        {:ok, %{}}
    end

    @impl true
    def handle_cast({:print, tweet}, _) do
        IO.inspect(self())
        {:noreply, IO.puts(tweet)}
    end

end