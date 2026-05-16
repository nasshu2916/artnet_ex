defmodule ArtNet.Packet.EnumTable.TodDataCommandResponse do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    tod_full: 0x00,
    tod_nak: 0xFF
  )
end
