defmodule ChangiTest do
  use ExUnit.Case
  doctest Changi

  test "greets the world" do
    assert Changi.hello() == :world
  end

  @arrival File.read!("arrival.json") |> Jason.decode!()
  @departure File.read!("departure.json") |> Jason.decode!()
  describe "format_flight/1" do
    test "format arrival (with estimated time)" do
      assert Changi.format_flight(@arrival, "3K520") == """
             *3K520*
             JETSTAR ASIA
             Arriving from Bangkok (Suvarnabhumi)
             Scheduled time: 20190730 15:10:00
             Estimated time: 14:46

             Status: *Confirmed*

             T1
             Luggage at belt 10
             """
    end

    test "format arrival (without estimated time)" do
      arrival = %{@arrival | "estimationTimeFlag" => false, "estimatedTime" => ""}

      assert Changi.format_flight(arrival, "3K520") == """
             *3K520*
             JETSTAR ASIA
             Arriving from Bangkok (Suvarnabhumi)
             Scheduled time: 20190730 15:10:00

             Status: *Confirmed*

             T1
             Luggage at belt 10
             """
    end

    test "format departure (with estimated time)" do
      assert Changi.format_flight(@departure, "SQ318") == """
             *SQ318*
             SINGAPORE AIRLINES
             Destination: London
             Scheduled time: 20190730 12:35:00
             Estimated time: 12:55

             Status: *Departed*

             T3
             Check-in at row 04 (door 3)
             Board at gate A14
             """
    end

    test "format departure (without estimated time)" do
      departure = %{@departure | "estimationTimeFlag" => false, "estimatedTime" => ""}

      assert Changi.format_flight(departure, "SQ318") == """
             *SQ318*
             SINGAPORE AIRLINES
             Destination: London
             Scheduled time: 20190730 12:35:00

             Status: *Departed*

             T3
             Check-in at row 04 (door 3)
             Board at gate A14
             """
    end

    test "codeshare flight" do
      assert Changi.format_flight(@departure, "NZ3318") == """
             *NZ3318*
             AIR NEW ZEALAND
             Operated by: SINGAPORE AIRLINES SQ318
             Destination: London
             Scheduled time: 20190730 12:35:00
             Estimated time: 12:55

             Status: *Departed*

             T3
             Check-in at row 04 (door 3)
             Board at gate A14
             """
    end
  end
end
