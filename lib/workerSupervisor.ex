defmodule WorkerSupervisor do
    use Supervisor

    def start() do
        children = [
            %{
                id: Worker0,
                start: {Worker,  :start, [0]}, 
            },
            %{
                id: Worker1,
                start: {Worker,  :start, [1]}
            },
            %{
                id: Worker2,
                start: {Worker,  :start, [2]}
            },
            %{
                id: Worker3,
                start: {Worker,  :start, [3]}
            },
            %{
                id: Worker4,
                start: {Worker,  :start, [4]}
            },
        ]


        opts = [strategy: :one_for_one]
        Supervisor.start_link(children, opts)
    end


    def init(state) do
        {:ok, state}
    end

end