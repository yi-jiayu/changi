defmodule Changi.DeparturesProxy do
  @moduledoc """
  Transparently fetches and caches departure information from the Changi Airport
  website to reduce API calls.
  """

  use Agent
  alias Changi.Client

  @ttl 60

  def start_link(_opts) do
    Agent.start_link(
      fn -> {~U[1970-01-01 00:00:00Z], nil} end,
      name: __MODULE__
    )
  end

  def get_departures do
    Agent.get_and_update(__MODULE__, fn {timestamp, departures} ->
      age = DateTime.diff(DateTime.utc_now(), timestamp)

      {timestamp, departures} =
        if age > @ttl,
          do: {DateTime.utc_now(), Client.get_departures()},
          else: {timestamp, departures}

      {departures, {timestamp, departures}}
    end)
  end
end
