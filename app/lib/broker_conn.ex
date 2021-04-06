defmodule BrokerConn do
  	use GenServer

  	def start_link(port) do
		{:ok, socket} = TCPServer.connect('broker', 8082)
    	GenServer.start_link(__MODULE__, %{socket: socket}, name: __MODULE__)
  	end

  	def init(state) do
    	{:ok, state}
 	end

  	def send(topic, message) do
    	GenServer.cast(__MODULE__, {:send, {topic, message}})
  	end

  	def handle_cast({:send, {topic, message}}, state) do
		data = Poison.encode!(%{type: "data", data: %{topic: topic, content: message}})

		TCPServer.send(state.socket, data)
    	{:noreply, state}
  	end
end
