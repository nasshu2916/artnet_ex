defmodule ArtNet.Packet.EnumTable.FailsafeState do
  @moduledoc """
  Failsafe state values used by `ArtNet.Packet.BitField.Status3`.

    * `:hold_last` - hold the last output state.
    * `:all_zero` - drive all output levels to zero.
    * `:all_full` - drive all output levels to full.
    * `:playback_scene` - play the recorded failsafe scene.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 2],
    hold_last: 0b00,
    all_zero: 0b01,
    all_full: 0b10,
    playback_scene: 0b11
  )
end
