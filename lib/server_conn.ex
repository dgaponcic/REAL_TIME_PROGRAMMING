defmodule ServerConn do
     
    def get_tweet() do
        receive do
            tweet -> 
                AutoScaler.rcv_data(tweet)
                Router.route(tweet)
        end
        get_tweet()
    end


    def start_link(url) do
        IO.puts("starting server conn")
        handle = spawn_link(__MODULE__, :get_tweet, [])
        {:ok, old_pid} = EventsourceEx.new(url, stream_to: handle)

        spawn_link(__MODULE__, :check_connection, [url, handle, old_pid])
        {:ok, self()}
    end


    def check_connection(url, handle, pid) do
        Process.monitor(pid)
        receive do
            err ->
                IO.puts("restarting")
                {ok, new_pid} = EventsourceEx.new(url, stream_to: handle)
                check_connection(url, handle, new_pid)
        end
    end
end



