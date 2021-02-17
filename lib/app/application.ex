defmodule App.Application do
    use Application
    
    @impl true
    def start(_type, _args) do
        url1 = "http://localhost:4000/tweets/1"
        url2 = "http://localhost:4000/tweets/2"

        children = [
            %{
              	id: Registry,
              	start: {Registry, :start_link, [:duplicate, Registry.ViaTest]}
            },

            %{
				id: AutoScaler,
				start: {AutoScaler, :start_link, []}
            },

            %{
				id: WorkerSupervisor,
				start: {WorkerSupervisor, :start_link, []},
            },

            %{
			    id: Router,
				start: {Router, :start_link, []}
            }, 

            %{
                id: ServerConn1,
                start: {ServerConn, :start_link, [url1]},
            },

            %{
                id: ServerConn2,
                start: {ServerConn, :start_link, [url2]},
            },

            %{
                id: TopHashtags,
                start: {TopHashtags, :start_link, []},
            },
        ]


        opts = [strategy: :one_for_one, max_restarts: 100, name: App.Supervisor]

        Supervisor.start_link(children, opts)

    end
end
