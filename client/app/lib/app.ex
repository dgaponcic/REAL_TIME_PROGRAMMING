defmodule App do
    def open() do
        IO.inspect("opened")
        {:ok, socket} = :gen_udp.open(8083, [:binary, {:active, false}])
        :gen_udp.send(socket, :broker, 8082, Poison.encode!(%{type: "subscribe", data: %{topic: "users"}}))
        IO.inspect("sent subscribe")
        socket
    end

    def rcv(socket) do
        IO.inspect("waiting for msg")
        IO.inspect(:gen_udp.recv(socket, 0))
        rcv(socket)
    end
end