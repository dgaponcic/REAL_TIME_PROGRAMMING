defmodule Register do
    use Agent

    def start_link() do
        Agent.start_link(fn -> %{} end, name: __MODULE__)
    end

    def get(key) do
        Agent.get(__MODULE__, fn dict -> Map.get(dict, key, []) end)
    end

    def add(key, value) do
        Agent.update(__MODULE__, fn registry -> Map.put(registry, key, [value | Map.get(registry, key, [])]) end)
    end

    def replace(key, value) do
        Agent.update(__MODULE__, fn registry -> Map.put(registry, key, value) end)
    end
end
