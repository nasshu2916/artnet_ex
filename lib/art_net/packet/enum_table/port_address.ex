defmodule ArtNet.Packet.EnumTable.PortAddress do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 2],
    unknown: 0b00,
    front: 0b01,
    net: 0b10,
    unused: 0b11
  )
end
