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

    def get_updated_records(id, records) do
        has_key = Map.has_key?(records, id)

        case has_key do
            false -> Map.put(records, id, %{})
            _ -> records
        end
    end

    def update_record(records, id, record_type, value) do
        record = Map.get(records, id)
        Map.put(record, record_type, value)
    end

    def handle_record(record_type, value, id, state) do
        records = get_updated_records(id, state.records)
        record = update_record(records, id, record_type, value)

        records = update_record_by_id(records, id, record)

        case get_nb_keys(record) do
            3 -> 
                Buffer.add_record(get_obj(record))
                Map.delete(state.records, id)
            _ -> 
                records
        end
    end


    def update_record_by_id(records, key, new_record) do
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
