defmodule Dispatcher do
    def handle_type("subscribe", client, msg) do
        topic = msg["params"]["topic"]
        %TypedMsgs.SubscribeMsg{topic: topic, client: client}
    end


    def handle_type("unsubscribe", _client, _msg) do
    end


    def handle_type("data", _client, msg) do
        topic = msg["params"]["topic"]
        content = msg["body"]["content"]
        %TypedMsgs.DataMsg{topic: topic, content: content}
    end

    
    def handle_type("connectPub", _client, msg) do
        topics = msg["topic"]
        %TypedMsgs.ConnectPubMsg{topics: topics}
    end


    def deserialize(client, data) do
        {:ok, parsed} = Poison.decode(data)
        msg = handle_type(parsed["type"], client, parsed)
        TypedMsgs.Acceptable.accept msg
    end
end
