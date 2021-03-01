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

end