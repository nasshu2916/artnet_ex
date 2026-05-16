defmodule ArtNet.Packet.EnumTable.RdmCommand do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    ar_process: 0x00
  )
end
