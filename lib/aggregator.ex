defmodule Aggregator do
    use GenServer

    def start_link() do
        IO.puts("starting aggregator")
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end


    def init(_state) do
        {:ok, %{}}
    end

    def add_sentiment(id, score) do
        GenServer.cast(__MODULE__, {:sentiment, {id, score}})
    end


    def add_engagement(id, score) do
        GenServer.cast(__MODULE__, {:engagement, {id, score}})
    end
        

    def add_tweet(id, tweet) do
        GenServer.cast(__MODULE__, {:tweet, {id, tweet}})
    end


    def get_record(true, id, state) do
        record = Map.get(state, id)
        {state, record}
    end

    def get_record(false, id, state) do
        state = Map.put(state, id, %{})
        {state, %{}}
    end

    def get_record(id, state) do
        has_key = Map.has_key?(state, id)
        get_record(has_key, id, state)
    end


    def handle_cast({:sentiment, {id, score}}, state) do
        state = handle_record("sentiment", score, id, state)
        {:noreply, state}
    end


    def handle_record(record_type, value, id, state) do
        {state, record} = get_record(id, state)
        new_record = add_field(record_type, value, record)
        state = update_state(state, id, new_record)
        nb_keys = get_nb_keys(new_record)

        send_record(state, id, new_record, nb_keys == 3)
    end


    def handle_cast({:engagement, {id, score}}, state) do
        state = handle_record("engagement", score, id, state)
        {:noreply, state}
    end


    def add_field(key, val, record) do
        Map.put(record, key, val)
    end


    def update_state(state, key, new_record) do
        Map.update!(state, key, fn _old_record -> new_record end)
    end


    def get_nb_keys(record) do
        record
        |> Map.keys() 
        |> Kernel.length()
    end


    def get_obj(record) do
        tweet = record["tweet"]
        user = tweet["user"]
        tweet = Map.update!(tweet, "user", fn user -> user["id"] end)

        %{
            tweet: %{
                engagement: record["engagement"],
                sentiment: record["sentiment"],
                tweet: tweet
            },
            user: user
        }
    end

    def send_record(state, key, record, true) do
        Sink.rcv_record(get_obj(record))
        Map.delete(state, key)
    end


    def send_record(state, _key, _record, false) do
        state
    end

    def handle_cast({:tweet, {id, tweet}}, state) do
        state = handle_record("tweet", tweet, id, state)
        {:noreply, state}
    end
end
