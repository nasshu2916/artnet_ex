defmodule ArtNet.Packet.EnumTable.TimeCodeType do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    film: 0x00,
    ebu: 0x01,
    drop_frame: 0x02,
    smpte: 0x03
  )
end
