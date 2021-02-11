defmodule ServerConn do
    
    def getTweet() do
        receive do
            tweet -> 
                # IO.inspect("new_ tweet")
                # GenServer.cast(:Router, {:route, tweet})
        end
        getTweet()
    end


    def start_link() do
        IO.puts("starting server conn")
        handle = spawn_link(__MODULE__, :getTweet, [])
        {:ok, old_pid} = EventsourceEx.new("http://localhost:4000/tweets/2", stream_to: handle)

        spawn_link(__MODULE__, :checkConnection, ["http://localhost:4000/tweets/2", handle, old_pid])
        {:ok, self()}
    end

    def checkConnection(url, handle, pid) do
        Process.monitor(pid)
        receive do
            err ->
                IO.puts("restarting")
                {ok, new_pid} = EventsourceEx.new(url, stream_to: handle)
                checkConnection(url, handle, new_pid)

        end
    end
end



