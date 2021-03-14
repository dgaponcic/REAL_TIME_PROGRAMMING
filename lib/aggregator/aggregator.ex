defmodule Aggregator do
    use GenServer

    def start_link() do
        IO.puts("starting aggregator")
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def init(_state) do
        {:ok, %{records: %{}}}
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
        record = Map.get(state.records, id)
        {state.records, record}
    end

    def get_record(false, id, state) do
        records = Map.put(state.records, id, %{})
        {records, %{}}
    end

    def get_record(id, state) do
        has_key = Map.has_key?(state.records, id)
        get_record(has_key, id, state)
    end


    def handle_cast({:tweet, {id, tweet}}, state) do
        records = handle_record("tweet", tweet, id, state)
        {:noreply, %{records: records}}
    end
    
    def handle_cast({:sentiment, {id, score}}, state) do
        records = handle_record("sentiment", score, id, state)
        {:noreply, %{records: records}}
    end

    def handle_cast({:engagement, {id, score}}, state) do
        records = handle_record("engagement", score, id, state)
        {:noreply, %{records: records}}
    end


    def handle_record(record_type, value, id, state) do
        {records, record} = get_record(id, state)

        new_record = add_field(record_type, value, record)
        records = update_records(records, id, new_record)

        case get_nb_keys(new_record) do
            3 -> 
                HealthState.send(get_obj(new_record))
                Map.delete(state.records, id)
            _ -> 
                records
        end
    end


    def add_field(key, val, record) do
        Map.put(record, key, val)
    end


    def update_records(records, key, new_record) do
        Map.update!(records, key, fn _old_record -> new_record end)
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
end
