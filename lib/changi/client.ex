defmodule Changi.Client do
  use Tesla
  adapter(Tesla.Adapter.Hackney)
  plug(Tesla.Middleware.BaseUrl, "https://www.changiairport.com")
  plug(Tesla.Middleware.JSON)

  def get_departures do
    {:ok, resp} = get("/cag-web/flights/departures", query: [lang: "en", date: "today"])

    with %{"success" => true, "carriers" => carriers} <- resp.body do
      carriers |> Enum.map(fn c -> {c["flightNo"], c} end) |> Enum.into(%{})
    end
  end

  def get_arrivals do
    {:ok, resp} = get("/cag-web/flights/arrivals", query: [lang: "en", date: "today"])

    with %{"success" => true, "carriers" => carriers} <- resp.body do
      carriers |> Enum.map(fn c -> {c["flightNo"], c} end) |> Enum.into(%{})
    end
  end
end
