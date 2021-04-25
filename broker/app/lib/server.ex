defmodule KVServer do
	require Logger

	def accept(port) do
    	{:ok, socket} = TCPServer.listen(port)
    	Logger.info "Accepting connections on port #{port}"
    	loop_acceptor(socket)
  	end

  	defp loop_acceptor(socket) do
    	{:ok, client} = TCPServer.accept(socket)
    	pid = spawn_link(__MODULE__, :serve, [client])
    	:gen_tcp.controlling_process(client, pid)
    	loop_acceptor(socket)
  	end

	def serve(:error, _client) do
		
	end

	def serve(data, client) do
		Dispatcher.deserialize(client, data)
        serve(client)
	end

    def serve(client) do
        data = TCPServer.read(client)
		serve(data, client)
    end
end
