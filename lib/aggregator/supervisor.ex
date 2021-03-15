defmodule AggregatorSupervisor do
    use Supervisor

    def start_link() do
        Supervisor.start_link(__MODULE__, %{}, name: __MODULE__)
    end
    
    def init(_) do
        children = [
            %{
                id: Buffer,
                start: {Buffer, :start_link, []}
            },

            %{
                id: Aggregator,
                start: {Aggregator, :start_link, []}
            }
        ]
    
        Supervisor.init(children, strategy: :one_for_all)
      end
end
