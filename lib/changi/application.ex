defmodule Changi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: Changi.Server, options: [port: 4001]),
      Changi.DeparturesProxy
    ]

    opts = [strategy: :one_for_one, name: Changi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
