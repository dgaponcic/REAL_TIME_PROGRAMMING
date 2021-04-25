defmodule App do
    def open() do
        {:ok, socket} = TCPServer.connect('127.0.0.1', 8082)
        msg = %TypedMsgs.SubscribeMsg{topic: "tweets"}

		data = TypedMsgs.Serializable.serialize msg
        TCPServer.send(socket, data)
        socket
    end

    def disconnect(socket) do
        msg = %TypedMsgs.UnsubscribeMsg{topic: "tweets"}
        data = TypedMsgs.Serializable.serialize msg
        TCPServer.send(socket, data)
    end

    def rcv(client, 1000) do
        data = TCPServer.read(client)
        IO.inspect(data, printable_limit: :infinity)
    end


    def rcv(client, i) do
        data = TCPServer.read(client)
        IO.inspect(data, printable_limit: :infinity)
        rcv(client, i + 1)
    end
end
