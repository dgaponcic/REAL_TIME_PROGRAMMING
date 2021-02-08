defmodule ServerConn do
    def get_tweet() do
        receive do
            tweet ->
                Manager.manage(tweet)
                get_tweet()
        end
    end

    def init() do
        EventsourceEx.new("localhost:4000/tweets/1", stream_to: self())
        get_tweet()
    end

end