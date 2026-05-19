defmodule ArtNet.Packet.EnumTable.Priority do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    dp_all: 0x00,
    dp_low: 0x10,
    dp_med: 0x40,
    dp_high: 0x80,
    dp_critical: 0xE0,
    dp_volatile: 0xF0
  )
end
