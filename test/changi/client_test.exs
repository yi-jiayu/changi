defmodule Changi.ClientTest do
  use ExUnit.Case
  use Plug.Test

  setup_all do
    Application.put_env(:tesla, Changi.Client, adapter: Tesla.Mock)
  end

  test "get_arrivals" do
    Tesla.Mock.mock(fn _ ->
      Tesla.Mock.json(%{
        "success" => true,
        "carriers" => [
          %{
            "flightNo" => "SQ621",
            "from" => "Osaka"
          },
          %{
            "flightNo" => "SQ633",
            "from" => "Tokyo (Haneda)",
            "slaves" => [
              %{
                "flightNo" => "ET1341"
              },
              %{
                "flightNo" => "NH6257"
              }
            ]
          }
        ]
      })
    end)

    assert %{
             "SQ621" => %{"flightNo" => "SQ621", "from" => "Osaka"},
             "SQ633" => %{
               "flightNo" => "SQ633",
               "from" => "Tokyo (Haneda)",
               "slaves" => [%{"flightNo" => "ET1341"}, %{"flightNo" => "NH6257"}]
             },
             "ET1341" => %{
               "flightNo" => "SQ633",
               "from" => "Tokyo (Haneda)",
               "slaves" => [%{"flightNo" => "ET1341"}, %{"flightNo" => "NH6257"}]
             },
             "NH6257" => %{
               "flightNo" => "SQ633",
               "from" => "Tokyo (Haneda)",
               "slaves" => [%{"flightNo" => "ET1341"}, %{"flightNo" => "NH6257"}]
             }
           } = Changi.Client.get_arrivals()
  end
end
