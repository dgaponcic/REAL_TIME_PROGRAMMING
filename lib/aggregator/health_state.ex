defmodule HealthState do
    use GenServer

    def start_link() do
        IO.inspect("starting health check")
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def init(_) do
        schedule_sink_health_check()
        {:ok, %{health_state: Sink.check_health_state()}}
    end


    def get_health_state() do
        try do
            Sink.check_health_state()
        catch
            :exit, _ -> :error
        end
    end


    def handle_info(:health_check, state) do
        schedule_sink_health_check()
        {:noreply, %{health_state: get_health_state()}}
    end

    def schedule_sink_health_check() do
        interval = 500
        Process.send_after(self(), :health_check, interval)
    end


    def get_health() do
        GenServer.call(__MODULE__, :get_health)
    end


    def handle_call(:get_health, _from, state) do
        {:reply, state.health_state, %{health_state: state.health_state}}
    end
end
