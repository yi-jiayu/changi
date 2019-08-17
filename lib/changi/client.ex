defmodule Changi.Client do
  use Tesla
  adapter(Tesla.Adapter.Hackney)
  plug(Tesla.Middleware.BaseUrl, "https://www.changiairport.com")
  plug(Tesla.Middleware.JSON)

  def get_departures do
    with {:ok, resp} <- get("/cag-web/flights/departures", query: [lang: "en", date: "today"]),
         %{"success" => true, "carriers" => carriers} <- resp.body do
      carriers
      |> Enum.flat_map(fn c ->
        [{c["flightNo"], c}] ++
          get_slaves_haha(c["slaves"], c)
      end)
      |> Enum.into(%{})
    end
  end

  def get_arrivals do
    with {:ok, resp} <- get("/cag-web/flights/arrivals", query: [lang: "en", date: "today"]),
         %{"success" => true, "carriers" => carriers} <- resp.body do
      carriers
      |> Enum.flat_map(fn c ->
        [{c["flightNo"], c}] ++
          get_slaves_haha(c["slaves"], c)
      end)
      |> Enum.into(%{})
    end
  end

  def get_slaves_haha(slaves, master) do
    if slaves do
      Enum.map(slaves, fn slave -> {slave["flightNo"], master} end)
    else
      []
    end
  end
end
