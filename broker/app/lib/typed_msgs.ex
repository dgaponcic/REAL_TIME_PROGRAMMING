defmodule TypedMsgs.SubscribeMsg do
    defstruct [:topic, :client]
end

defmodule TypedMsgs.DataMsg do
    defstruct [:topic, :content, :client]
end

defmodule TypedMsgs.ConnectPubMsg do
    defstruct [:topics, :client]
end



defprotocol TypedMsgs.Serializable do
    @spec serialize(t) :: TypedMsgs.t()
    def serialize(msg)
end

defimpl TypedMsgs.Serializable, for: TypedMsgs.DataMsg do
    def serialize(msg) do
        Poison.encode!(%{content: msg.content, topic: msg.topic})
    end
end




defprotocol TypedMsgs.Acceptable do
    @spec accept(t) :: TypedMsgs.t()
    def accept(msg)
end

defimpl TypedMsgs.Acceptable, for: TypedMsgs.SubscribeMsg do
    def accept(msg) do
        Registry.register(Registry.ViaTest, msg.topic, msg.client)
    end
end

defimpl TypedMsgs.Acceptable, for: TypedMsgs.DataMsg do
    def accept(msg) do
        clients = Registry.lookup(Registry.ViaTest, msg.topic)
        data = TypedMsgs.Serializable.serialize msg
        Enum.each(clients, fn {pid, port} -> TCPServer.send(port, data) end)
    end
end

defimpl TypedMsgs.Acceptable, for: TypedMsgs.ConnectPubMsg do
    def accept(msg) do
        
    end
end