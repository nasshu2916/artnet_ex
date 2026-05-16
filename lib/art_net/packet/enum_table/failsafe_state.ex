defmodule ArtNet.Packet.EnumTable.FailsafeState do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 2],
    hold_last: 0b00,
    all_zero: 0b01,
    all_full: 0b10,
    playback_scene: 0b11
  )
end
