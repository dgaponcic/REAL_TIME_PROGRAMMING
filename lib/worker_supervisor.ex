defmodule WorkerSupervisor do
    use DynamicSupervisor

    def start_link() do
        res = DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
        WorkerSupervisor.start_child(4)
        res
    end

    def get_nb_children() do
        DynamicSupervisor.count_children(__MODULE__).active
    end


    def start_child(0) do

    end

    def start_child(n) do
        index = DynamicSupervisor.count_children(__MODULE__).active
        {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, {Worker, index})

        start_child(n - 1)
    end

    def stop_child(0) do

    end

    def stop_child(n) do
        IO.puts("terminating worker")
        index = get_nb_children() - 1

        {_, child_pid} = Registry.lookup(Registry.ViaTest, "Worker" <> Integer.to_string(index))
        |> Enum.take(-1)
        |> Enum.at(0)

        DynamicSupervisor.terminate_child(__MODULE__, child_pid)
        stop_child(n - 1)
    end

    
    @impl true
    def init(_init_arg) do
        DynamicSupervisor.init(max_restarts: 100, strategy: :one_for_one)
    end

end
