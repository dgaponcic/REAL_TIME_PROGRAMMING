defmodule ServerConn do

    def getTweet() do
        receive do
            tweet ->
                Router.route(tweet)
                getTweet()
        end
    end

    def start() do
        IO.puts("starting server conn")
        EventsourceEx.new("localhost:4000/tweets/1", stream_to: self())
        getTweet()
    end

end