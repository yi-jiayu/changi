defmodule Departures.Proxy do
  use Agent
  alias Departures.Client

  @ttl 60

  def start_link(_opts) do
    Agent.start_link(
      fn -> upstream_fetch() end,
      name: __MODULE__
    )
  end

  def find(flight_number) do
    Agent.get_and_update(__MODULE__, fn {timestamp, departures} ->
      age = DateTime.diff(DateTime.utc_now(), timestamp)

      {timestamp, departures} =
        if age > @ttl,
          do: upstream_fetch(),
          else: {timestamp, departures}

      result = Map.get(departures, flight_number)
      {result, {timestamp, departures}}
    end)
  end

  defp upstream_fetch do
    {DateTime.utc_now(), Client.get_departures()}
  end
end
