defmodule Changi.Proxy do
  @moduledoc """
  Transparently fetches and caches flight information from the Changi Airport
  website to reduce API calls.
  """

  use Agent

  @ttl 60

  def start_link(_opts) do
    Agent.start_link(
      fn -> {~U[1970-01-01 00:00:00Z], nil} end,
      name: __MODULE__
    )
  end

  def get_flights do
    Agent.get_and_update(__MODULE__, fn {timestamp, flights} ->
      age = DateTime.diff(DateTime.utc_now(), timestamp)

      {timestamp, flights} =
        if age > @ttl,
          do: {DateTime.utc_now(), Changi.get_flights()},
          else: {timestamp, flights}

      {flights, {timestamp, flights}}
    end)
  end
end
