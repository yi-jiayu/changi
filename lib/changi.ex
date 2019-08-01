defmodule Changi do
  @moduledoc """
  Documentation for Changi.
  """

  alias Changi.Client

  @doc """
  Hello world.

  ## Examples

      iex> Changi.hello()
      :world

  """
  def hello do
    :world
  end

  def get_flights do
    arrivals = Task.async(fn -> Client.get_arrivals() end)
    departures = Task.async(fn -> Client.get_departures() end)
    Map.merge(Task.await(arrivals), Task.await(departures))
  end

  def format_flight(%{"to" => _} = departure) do
    """
    *#{departure["flightNo"]}*
    #{departure["airlineDesc"]}
    Destination: #{departure["to"]}
    Scheduled time: #{departure["scheduledDatetime"]}

    Status: *#{departure["status"]}*

    T#{departure["terminal"]}
    Check-in at row #{departure["checkInRow"]}
    Board at gate #{departure["gate"]}
    """
  end

  def format_flight(%{"from" => _} = arrival) do
    """
    *#{arrival["flightNo"]}*
    #{arrival["airlineDesc"]}
    Arriving from #{arrival["from"]}
    Scheduled time: #{arrival["scheduledDatetime"]}

    Status: *#{arrival["status"]}*

    T#{arrival["terminal"]}
    Luggage at belt #{arrival["belt"]}
    """
  end
end
