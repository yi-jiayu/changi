defmodule Changi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.get_env(:changi, :port, 4000)

    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: Changi.Server, options: [port: port]),
      Changi.Proxy
    ]

    opts = [strategy: :one_for_one, name: Changi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
