defmodule ArtNet.Packet.EnumTable.PortType do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 6],
    dmx512: 0b0000,
    midi: 0b0001,
    avab: 0b0010,
    colortran: 0b0011,
    adb: 0b0100,
    art_net: 0b0101,
    dali: 0b0110
  )
end
