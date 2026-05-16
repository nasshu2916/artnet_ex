defmodule ArtNet.Packet.EnumTable.PriorityTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.EnumTable.Priority

  test "uses Art-Net diagnostics priority values" do
    [
      dp_all: 0x00,
      dp_low: 0x10,
      dp_med: 0x40,
      dp_high: 0x80,
      dp_critical: 0xE0,
      dp_volatile: 0xF0
    ]
    |> Enum.each(fn {priority, value} ->
      assert Priority.to_code(priority) == {:ok, value}
      assert Priority.to_atom(value) == {:ok, priority}
    end)
  end
end
