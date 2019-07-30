import Config

config :changi, :port, System.get_env("PORT", "8080") |> String.to_integer()
