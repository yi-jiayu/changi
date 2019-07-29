defmodule Departures.Client do
  use Tesla
  adapter(Tesla.Adapter.Hackney)
  plug(Tesla.Middleware.BaseUrl, "https://www.changiairport.com")
  plug(Tesla.Middleware.JSON)

  def get_departures do
    {:ok, resp} = get("/cag-web/flights/departures", query: [lang: "en", date: "today"])

    with %{"success" => true, "carriers" => departures} <- resp.body do
      departures |> Enum.map(fn d -> {d["flightNo"], d} end) |> Enum.into(%{})
    end
  end
end
