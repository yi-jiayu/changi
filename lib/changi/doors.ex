defmodule Changi.Doors do
  @doors Application.app_dir(:changi, "priv/doors.json") |> File.read!() |> Jason.decode!()
  def door_for(%{"terminal" => terminal, "checkInRow" => check_in_row}) do
    @doors["T" <> terminal][check_in_row]
  end
end
