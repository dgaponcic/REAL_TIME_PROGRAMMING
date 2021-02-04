defmodule Manager do
    use GenServer

    def start() do
        children = [
            Printer.start(0),
            Printer.start(1),
            Printer.start(2)
        ]

        GenServer.start_link(__MODULE__, %{index: 0, children: children}, name: __MODULE__)
    end

    def manage(tweet) do
        GenServer.cast(__MODULE__, {:manage, tweet.data})
    end


    @impl true
    def init(state) do
        {:ok, state}
    end

    @impl true
    def handle_cast({:manage, tweet}, state) do

        Enum.at(state.children, rem(state.index, 3))
        |> Tuple.to_list()
        |> Enum.at(1)
        |> GenServer.cast({:print, tweet})

        {:noreply,  %{index: state.index + 1, children: state.children}}
    end

end