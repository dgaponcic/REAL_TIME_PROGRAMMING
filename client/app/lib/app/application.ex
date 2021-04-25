defmodule App.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]
    socket = App.open()
    
    # :timer.sleep(200000)
    App.rcv(socket, 1)
    App.disconnect(socket)
    Supervisor.start_link(children, opts)
  end
end
