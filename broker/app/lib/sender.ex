defmodule Sender do

    def send(msg) do
        clients = Register.get(msg.topic)
        data = TypedMsgs.Serializable.serialize msg
        Enum.each(clients, fn port -> 
            try do
                TCPServer.send(port, data)
            rescue
                _ -> IO.inspect("oops")
            end
        end)
    end

    def remove_client(with_error) do
        topics = Register.get("topics")
        Enum.each(topics, fn topic ->
            clients = Register.get(topic)
            Enum.each(with_error, fn client -> 
                updated_clients = List.delete(clients, client)
                Register.replace(topic, updated_clients)
            end)
        end)
    end

    def update(with_error, ttl, id) do
        cond do
            length(with_error) > 0 and ttl > 0 ->
                Queue.add(id, with_error, ttl - 1)

            length(with_error) > 0 ->
                remove_client(with_error)
                MongoConnection.delete(id)

            true ->
                MongoConnection.delete(id)
        end
    end


    def send_persistent(clients, data) do
        Enum.reduce(clients, [], fn port, acc -> 
            try do
                :ok = TCPServer.send(port, data)
                acc
            rescue
                a -> [port | acc]
            end
        end)
    end


    def send_persistent(msg, clients, id, ttl) do
        data = TypedMsgs.Serializable.serialize msg
        with_error = send_persistent(clients, data)
        IO.inspect({"with error", with_error})
        update(with_error, ttl, id)
    end
end
