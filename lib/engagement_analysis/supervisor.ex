defmodule EngagementAnalysis.Supervisor do
    use DynamicSupervisor

    def start_link() do
        supervisor = DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
        EngagementAnalysis.Supervisor.start_child(4)
        supervisor
    end

    def get_nb_children() do
        DynamicSupervisor.count_children(__MODULE__).active
    end


    def start_child(0) do

    end

    def start_child(n) do
        index = DynamicSupervisor.count_children(__MODULE__).active
        DynamicSupervisor.start_child(__MODULE__, {EngagementAnalysis.Worker, index})
        start_child(n - 1)
    end

    def stop_child(0) do

    end


    def stop_child(n) do
        # IO.puts("terminating worker")
        index = get_nb_children() - 1
        child_pid = get_child_pid("engagementWorker" <> Integer.to_string(index))
        DynamicSupervisor.terminate_child(__MODULE__, child_pid)

        stop_child(n - 1)
    end
    

    defp get_child_pid(name) do
        {_, child_pid} = Registry.lookup(Registry.ViaTest, name)
        |> Enum.take(-1)
        |> Enum.at(0)

        child_pid
    end


    def init(_) do
        DynamicSupervisor.init(max_restarts: 100, strategy: :one_for_one)
    end
end
