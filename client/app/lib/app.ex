defmodule App do
    def open() do
        {:ok, socket} = TCPServer.connect('broker', 8082)
        msg = %TypedMsgs.SubscribeMsg{topic: "users"}
		data = TypedMsgs.Serializable.serialize msg
        TCPServer.send(socket, data)
        socket
    end


    def rcv(client) do
        data = TCPServer.read(client)
        IO.inspect(data, printable_limit: :infinity)
        rcv(client)
    end
end
