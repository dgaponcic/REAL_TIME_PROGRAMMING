defmodule Dispatcher do
    def handle_type("subscribe", client, data) do
        topic = data["topic"]
        Registry.register(Registry.ViaTest, topic, client)
        IO.inspect("subscribed")
    end


    def handle_type("data", _client, data) do
        topic = data["topic"]
        content = data["content"]
        clients = Registry.lookup(Registry.ViaTest, topic)

        Enum.each(clients, fn {pid, port} -> TCPServer.send(port, Poison.encode!(data)) end)

        IO.inspect("sent")
    end

    def dispatch(client, data) do
        {:ok, parsed} = Poison.decode(data)
        type = parsed["type"]
        data = parsed["data"]
        handle_type(type, client, data)
    end


end