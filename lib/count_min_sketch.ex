defmodule CountMinSketch do
    def new(rows, columns) do
        sketch = for _ <- 1..columns, do: for _ <- 1..rows, do: 0
        hashes = for i <- 1..columns, do: get_hash_f("salt" <> Integer.to_string(i), rows)
        %{
            sketch: sketch, 
            hashes: hashes, 
            rows: rows, 
            columns: columns
        }
    end


    def get_hash_f(salt, rows) do
        fn(input) -> 
            {val, _} = :crypto.hash(:md5, salt <> input) 
            |> Base.encode16() 
            |> Integer.parse(16)
            
            rem(val, rows)
        end
    end


    def get_hash_vals(sketch, input) do
        sketch.hashes
        |> Enum.map(fn hash -> hash.(input) end)
    end


    def add2sketch(sketch, input) do
        hash_vals = get_hash_vals(sketch, input)
        
        new_sketch = sketch.sketch
        |> Enum.zip(hash_vals)
        |> Enum.map(fn {arr, index} -> List.update_at(arr, index, &(&1 + 1)) end)

        %{sketch: new_sketch, hashes: sketch.hashes, rows: sketch.rows, columns: sketch.columns}
    end


    def get(sketch, input) do
        hash_vals = get_hash_vals(sketch, input)

        sketch.sketch
        |> Enum.zip(hash_vals)
        |> Enum.map(fn {arr, index} -> Enum.at(arr, index) end)
        |> Enum.min()
    end
end
