defmodule TypedMsgs.SubscribeMsg do
    defstruct [:topic]
end

defmodule TypedMsgs.UnsubscribeMsg do
    defstruct [:topic]
end

defmodule TypedMsgs.DataMsg do
    defstruct [:topic, :content]
end

defmodule TypedMsgs.ConnectPubMsg do
    defstruct [:topics]
end


defprotocol TypedMsgs.Serializable do
    @spec serialize(t) :: TypedMsgs.t()
    def serialize(msg)
end

defimpl TypedMsgs.Serializable, for: TypedMsgs.ConnectPubMsg do
    def serialize(msg) do
        Poison.encode!(%{type: "connectPub", params: %{topics: msg.topics}})
    end
end


defimpl TypedMsgs.Serializable, for: TypedMsgs.DataMsg do
    def serialize(msg) do
        Poison.encode!(%{type: "data", params: %{topic: msg.topic}, body: %{content: msg.content}})
    end
end

defimpl TypedMsgs.Serializable, for: TypedMsgs.SubscribeMsg do
    def serialize(msg) do
        Poison.encode!(%{type: "subscribe", params: %{topic: msg.topic}})
    end
end

defimpl TypedMsgs.Serializable, for: TypedMsgs.UnsubscribeMsg do
    def serialize(msg) do
        Poison.encode!(%{type: "unsubscribe", params: %{topic: msg.topic}})
    end
end