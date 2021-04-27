defmodule BrokerConn do
  	use GenServer

  	def start_link(port) do
		{:ok, socket} = TCPServer.connect('broker', 8082)
		connMsg = %TypedMsgs.ConnectPubMsg{topics: ["tweets", "users"]}
		data = TypedMsgs.Serializable.serialize connMsg
		TCPServer.send(socket, data)
    	GenServer.start_link(__MODULE__, %{socket: socket}, name: __MODULE__)
  	end

  	def init(state) do
    	{:ok, state}
 	end

  	def send(topic, message) do
    	GenServer.cast(__MODULE__, {:send, {topic, message}})
  	end

  	def handle_cast({:send, {topic, message}}, state) do
		msg = %TypedMsgs.DataMsg{topic: topic, content: message, is_persistent: true}
		data = TypedMsgs.Serializable.serialize msg
		TCPServer.send(state.socket, data)
    	{:noreply, state}
  	end
end
