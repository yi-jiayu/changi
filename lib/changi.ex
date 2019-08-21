defmodule Changi do
  @moduledoc """
  Documentation for Changi.
  """

  require EEx
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

  EEx.function_from_file(
    :defp,
    :departure_template,
    Application.app_dir(:changi, "priv/departure.eex"),
    [:assigns]
  )

  def format_flight(%{"to" => _} = flight, flight_no) do
    if flight_no == flight["flightNo"] do
      departure_template(flight: flight, flight_no: nil, airline_desc: nil)
    else
      airline_desc =
        flight["slaves"]
        |> Enum.find(fn s -> s["flightNo"] == flight_no end)
        |> Map.get("airlineDesc")

      departure_template(flight: flight, flight_no: flight_no, airline_desc: airline_desc)
    end
  end

  EEx.function_from_file(
    :defp,
    :arrival_template,
    Application.app_dir(:changi, "priv/arrival.eex"),
    [:assigns]
  )

  def format_flight(%{"from" => _} = flight, flight_no) do
    if flight_no == flight["flightNo"] do
      arrival_template(flight: flight, flight_no: nil, airline_desc: nil)
    else
      airline_desc =
        flight["slaves"]
        |> Enum.find(fn s -> s["flightNo"] == flight_no end)
        |> Map.get("airlineDesc")

      arrival_template(flight: flight, flight_no: flight_no, airline_desc: airline_desc)
    end
  end
end
