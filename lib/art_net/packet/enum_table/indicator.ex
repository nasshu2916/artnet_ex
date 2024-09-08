defmodule ArtNet.Packet.EnumTable.Indicator do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 2],
    unknown: 0b00,
    locate: 0b01,
    mute: 0b10,
    normal: 0b11
  )
end
