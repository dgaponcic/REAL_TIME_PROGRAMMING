defmodule Router do
    use GenServer

    def start() do

        children = [
            :Worker0,
            :Worker1,
            :Worker2,
            :Worker3,
            :Worker4,
        ]

        GenServer.start_link(__MODULE__, %{index: 0, children: children}, name: __MODULE__)
    end

    def route(tweet) do
        GenServer.cast(__MODULE__, {:route, tweet.data})
    end


    @impl true
    def init(state) do
        {:ok, state}
    end

    @impl true
    def handle_cast({:route, tweet}, state) do
        Enum.at(state.children, rem(state.index, 5))
        |> GenServer.cast({:print, tweet})

        {:noreply,  %{index: state.index + 1, children: state.children}}
    end

end