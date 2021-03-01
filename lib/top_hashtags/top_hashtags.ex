defmodule TopHashtags do
    use GenServer 

    def start_link() do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end


    defp rcv_data(tweet, false) do
        {:ok, tweet} = Poison.decode(tweet)
        tweet["message"]["tweet"]["entities"]["hashtags"]
        |> Enum.each(fn hashtag -> GenServer.cast(__MODULE__, {:hashtag, hashtag["text"]}) end)
    end


    defp rcv_data(_tweet, true) do 

    end


    def rcv_data(tweet) do
        rcv_data(tweet, tweet =~ "panic")
    end

    def update_top_hashtag(head, [], val, score) do
        {head, tail} = Enum.split_while(head, fn hashtag -> hashtag.score > score end)

        {_, tail} = tail
        |> List.insert_at(0, %{hashtag: val, score: score})
        |> List.pop_at(-1)

        head ++ tail
    end


    def update_top_hashtag(head, tail, val, score) do
        {_, tail} = List.pop_at(tail, 0)
        top = head ++ tail
        {head, tail} = Enum.split_while(top, fn hashtag -> hashtag.score > score end)
        tail = List.insert_at(tail, 0, %{hashtag: val, score: score})
        head ++ tail
    end


    def update_top(true, val, top, score) do
        {head, tail} = Enum.split_while(top, fn hashtag -> hashtag.hashtag != val end)
        update_top_hashtag(head, tail, val ,score)
    end


    def update_top(false, _val, top, _score) do
        top
    end


    defp create_sketch(popular_hashtags) do
        rows = 10
        columns = 15
        sketch = CountMinSketch.new(rows, columns)
        
        popular_hashtags
        |> Enum.reduce(sketch, fn hashtag, acc -> CountMinSketch.add2sketch(acc, hashtag) end) 
    end


    def init(_state) do
        schedule_work()

        popular_hashtags = ["health", "beauty", "football", "America", "China", "burger", "life", "sport", "movie", "wine"]
        sketch = create_sketch(popular_hashtags)
        top = popular_hashtags
        |> Enum.map(fn hashtag -> %{hashtag: hashtag, score: 1} end)

        {:ok, %{sketch: sketch, top: top}}
    end


    def handle_cast({:hashtag, hashtag}, state) do
        new_sketch = CountMinSketch.add2sketch(state.sketch, hashtag)
        score = CountMinSketch.get(state.sketch, hashtag)
        
        top = (List.last(state.top).score < score)
        |> update_top(hashtag, state.top, score)

        {:noreply, %{sketch: new_sketch, top: top}}
    end


    def handle_info(:work, state) do
        # IO.inspect(state.top)
        schedule_work()
        {:noreply, state}
    end


    defp schedule_work() do
        interval = 1000
        Process.send_after(self(), :work, interval)
    end
end