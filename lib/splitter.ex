defmodule Splitter do
    def get_obj(record) do
        {:ok, tweet} = Poison.decode(record["tweet"])
        tweet = tweet["message"]["tweet"]
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
