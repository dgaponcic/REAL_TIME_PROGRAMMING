defmodule TCPServer do

    def listen(port) do
        :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true])
    end

    def accept(socket) do
        :gen_tcp.accept(socket)
    end

    def connect(host, port) do
        :gen_tcp.connect(host, port, [:binary, active: false])
    end

    def send(socket, data) do
        size = data 
		|> String.length()
		|> Integer.to_string()
		|> String.pad_leading(5, "0")

        :gen_tcp.send(socket, size <> data)
    end


    defp get_size(desired, actual) do
        diff = desired - actual
        if diff > 512 do
            512
        else
            diff
        end
    end

    defp read(true, client, acc, size) do
        to_read = get_size(size, String.length(acc))
        {_status, data} = :gen_tcp.recv(client, to_read)
        new_data = acc <> data
        read(String.length(new_data) < size, client, new_data, size)
    end

    defp read(false, _, acc, _) do
      acc
    end

    def read(socket) do
        {_status, size} = :gen_tcp.recv(socket, 5)
        read(true, socket, "", String.to_integer(size))
    end
end