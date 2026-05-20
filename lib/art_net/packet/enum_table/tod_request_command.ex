defmodule ArtNet.Packet.EnumTable.TodRequestCommand do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    tod_full: 0x00
  )
end
