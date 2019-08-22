defmodule Changi.DoorsTest do
  use ExUnit.Case

  @departure %{"terminal" => "2", "checkInRow" => "04"}
  test "door_for" do
    assert Changi.Doors.door_for(@departure) == 2
  end
end
