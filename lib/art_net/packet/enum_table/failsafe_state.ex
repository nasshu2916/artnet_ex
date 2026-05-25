defmodule ArtNet.Packet.EnumTable.FailsafeState do
  @moduledoc """
  Failsafe state values used by `ArtNet.Packet.BitField.Status3`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 2],
    hold_last: {0b00, description: "Hold the last output state."},
    all_zero: {0b01, description: "Drive all output levels to zero."},
    all_full: {0b10, description: "Drive all output levels to full."},
    playback_scene: {0b11, description: "Play the recorded failsafe scene."}
  )
end
