defmodule Dispatcher do
    def handle_type(:subscribe, client, msg) do
        topic = msg["params"]["topic"]
        %TypedMsgs.SubscribeMsg{topic: topic, client: client}
    end


    def handle_type(:unsubscribe, client, msg) do
        topic = msg["params"]["topic"]
        %TypedMsgs.UnsubscribeMsg{topic: topic, client: client}
    end


    def handle_type(:data, _client, msg) do
        topic = msg["params"]["topic"]
        content = msg["body"]["content"]
        is_persistent = msg["params"]["is_persistent"]

        %TypedMsgs.DataMsg{topic: topic, content: content, is_persistent: is_persistent}
    end


    def handle_type(:connectPub, _client, msg) do
        topics = msg["params"]["topics"]
        %TypedMsgs.ConnectPubMsg{topics: topics}
    end


    def deserialize(client, data) do
        try do
            {:ok, parsed} = Poison.decode(data)
            msg = handle_type(String.to_atom(parsed["type"]), client, parsed)
            TypedMsgs.Acceptable.accept msg
        rescue
            _ -> IO.inspect({"can't parse", data})
        end
    end
end
