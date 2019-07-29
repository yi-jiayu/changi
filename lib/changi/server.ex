defmodule Changi.Server do
  use Plug.Router

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
      if departure = Changi.Proxy.find(flight_number),
        do: Map.get(departure, "status"),
        else: "Not found!"

    reply(conn, chat_id, text)
  end

  def reply(conn, chat_id, text) do
    body = %{method: "sendMessage", chat_id: chat_id, text: text}

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(body))
  end
end
