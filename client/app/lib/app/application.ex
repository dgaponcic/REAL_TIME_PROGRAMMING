defmodule App.Application do
	use Application

	@impl true
	def start(_type, _args) do
		children = [
		]

		opts = [strategy: :one_for_one, name: App.Supervisor]
		socket = App.open()
		
		App.rcv(socket, 1)
		App.disconnect(socket)
		Supervisor.start_link(children, opts)
	end
end
