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


    def task_done(index) do
        GenServer.cast(__MODULE__, {:task_done, index})
    end


    defp define_active_tasks(range) do
        Enum.reduce(range, [], fn index, acc -> 
            acc ++ [
                %{
                    name: String.to_atom("Worker" <> Integer.to_string(index)), 
                    index: index,
                    val: 0
                }
            ]
        end)
    end

    
    def init(_state) do
        range = 0..WorkerSupervisor.get_nb_children() - 1
        active_tasks = define_active_tasks(range)
        
        {:ok, %{active_tasks: active_tasks, total_workers: WorkerSupervisor.get_nb_children()}}
    end


    defp update_active_tasks(true, active_tasks, diff) do
        init_index = length(active_tasks)
        range = init_index..init_index + diff
        new_workers = define_active_tasks(range)

        active_tasks ++ new_workers
    end


    defp update_active_tasks(false, active_tasks, diff) do
        Enum.drop(active_tasks, -diff)
    end


    defp update_active_tasks(old_workers, new_workers, active_tasks) do
        update_active_tasks(new_workers > old_workers, active_tasks, abs(new_workers - old_workers))
    end


    def update_value_tasks(tasks, index, worker, fun) do
        List.update_at(
            tasks, 
            index,
            &(%{name: worker.name, index: worker.index, val: fun.(&1.val)})
        )
    end


    defp choose_worker(active_tasks) do
        Enum.min_by(active_tasks, fn worker -> worker.val end)
    end


    def handle_cast({:task_done, index}, state) do
        worker = Enum.at(state.active_tasks, index)
        active_tasks = update_value_tasks(state.active_tasks, index, worker, &(&1 - 1))
        
        {:noreply, %{active_tasks: active_tasks, total_workers: state.total_workers}}
    end


    def handle_cast({:route, tweet}, state) do
        worker = choose_worker(state.active_tasks)
        active_tasks = update_value_tasks(state.active_tasks, worker.index, worker, &(&1 - 1))

        GenServer.cast(worker.name, {:print, tweet})

        new_workers = WorkerSupervisor.get_nb_children()
        old_workers = state.total_workers
        active_tasks= update_active_tasks(old_workers, new_workers, active_tasks)

        {:noreply,  %{active_tasks: active_tasks, total_workers: new_workers}}
    end
end
