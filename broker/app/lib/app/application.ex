defmodule App.Application do
  	use Application

  	@impl true
  	def start(_type, _args) do
    	children = [
			%{
            	id: QueueReleaser,
            	start: {QueueReleaser, :start_link, []}
       		},

			%{
            	id: Register,
            	start: {Register, :start_link, []}
       		},
			
			%{
            	id: Queue,
            	start: {Queue, :start_link, []}
       		},

			%{
            	id: MongoConnection,
            	start: {MongoConnection, :start_link, []}
       		},
		
			%{
				id: KVServer,
				start: {KVServer, :accept, [8082]}
			}
    	]

    	opts = [strategy: :one_for_one, name: App.Supervisor]
    	Supervisor.start_link(children, opts)
  	end
end
