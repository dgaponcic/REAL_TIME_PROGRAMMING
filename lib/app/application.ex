defmodule App.Application do
  use Application
  
  @impl true
  def start(_type, _args) do

    children = [
      # {Registry, keys: :unique, name: GreeterRegistry},

      %{
        id: WorkerSupervisor,
        start: {WorkerSupervisor, :start, []}
      },

      %{
        id: Router,
        start: {Router, :start, []}
      }, 

      %{
        id: ServerConn,
        start: {ServerConn, :start, []}
      },
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
