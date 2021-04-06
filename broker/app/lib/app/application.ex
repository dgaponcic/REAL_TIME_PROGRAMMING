defmodule App.Application do
  	use Application

  	@impl true
  	def start(_type, _args) do
    	children = [
			%{
            	id: Registry,
            	start: {Registry, :start_link, [:duplicate, Registry.ViaTest]}
       		},
		
        	Supervisor.child_spec({Task, fn -> KVServer.accept(8082) end}, restart: :permanent)
    	]

    	opts = [strategy: :one_for_one, name: App.Supervisor]
    	Supervisor.start_link(children, opts)
  	end
end
