defmodule App do
    def open() do
        {:ok, socket} = TCPServer.connect('broker', 8082)
        data = Poison.encode!(%{type: "subscribe", data: %{topic: "users"}})
        TCPServer.send(socket, data)
        socket
    end


    def rcv(client) do
        data = TCPServer.read(client)
        IO.inspect(data, printable_limit: :infinity)
        rcv(client)
    end
end
