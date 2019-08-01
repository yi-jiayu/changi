defmodule Changi.Server do
  use Plug.Router
  alias Changi.Proxy

  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, :ok, "pong")
  end

  post "/telegram/updates" do
    case conn.params do
      %{
        "message" => %{
          "chat" => %{
            "id" => chat_id
          },
          "text" => text
        },
        "update_id" => _
      } ->
        send_departure_info(conn, chat_id, text)

      _ ->
        send_resp(conn, :ok, "")
    end
  end

  match _ do
    send_resp(conn, :not_found, "")
  end

  def send_departure_info(conn, chat_id, text) do
    flight_number = text |> String.upcase() |> String.replace(" ", "")

    text =
      Proxy.get_flights()
      |> Map.get(flight_number)
      |> case do
        nil -> "Not found!"
        departure -> Changi.format_flight(departure)
      end

    reply(conn, chat_id, text)
  end

  def reply(conn, chat_id, text) do
    resp = %{method: "sendMessage", chat_id: chat_id, text: text, parse_mode: "Markdown"}
    json(conn, resp)
  end

  def json(conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(data))
  end
end
