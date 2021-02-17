defmodule Router do
    use GenServer

    def start_link() do
        IO.puts("starting router")
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def route(tweet) do
        TopHashtags.rcv_data(tweet.data)
        GenServer.cast(__MODULE__, {:route, tweet.data})
    end


    @impl true
    def init(_state) do
        {:ok, %{index: 0, total_workers: WorkerSupervisor.get_nb_children()}}
    end

    @impl true
    def handle_cast({:route, tweet}, state) do
        String.to_atom("Worker" <> Integer.to_string(rem(state.index, state.total_workers)))
        |> GenServer.cast({:print, tweet})

        {:noreply,  %{index: state.index + 1, total_workers: WorkerSupervisor.get_nb_children()}}
    end

end