defmodule TypedMsgs.SubscribeMsg do
    defstruct [:topic, :client]
end

defmodule TypedMsgs.UnsubscribeMsg do
    defstruct [:topic, :client]
end

defmodule TypedMsgs.DataMsg do
    defstruct [:topic, :content, :is_persistent]
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
        is_topic = Enum.member?(Register.get("topics"), msg.topic)
        if is_topic do
            Register.add(msg.topic, msg.client)
        end
    end
end

defimpl TypedMsgs.Acceptable, for: TypedMsgs.UnsubscribeMsg do
    def accept(msg) do
        is_topic = Enum.member?(Register.get("topics"), msg.topic)
        if is_topic do
            clients = Register.get(msg.topic) 
            updated_clients = List.delete(clients, msg.client)
            Register.replace(msg.topic, updated_clients)
        end
    end
end

defimpl TypedMsgs.Acceptable, for: TypedMsgs.DataMsg do
    def accept(msg) do
        if msg.is_persistent do
            id = MongoConnection.insert(msg)
            clients = Register.get(msg.topic)
            ttl = 3
            Sender.send_persistent(msg, clients, id, ttl)
        else
            Sender.send(msg)
        end
    end
end

defimpl TypedMsgs.Acceptable, for: TypedMsgs.ConnectPubMsg do
    def accept(msg) do    
        Enum.each(msg.topics, fn topic -> 
            is_member = Enum.member?(Register.get("topics"), topic)
            if not is_member do
                Register.add("topics", topic) 
            end
        end)
    end
end
