defmodule ArtNet.Packet.EnumTable.FirmwareReplyType do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    firm_block_good: 0x00,
    firm_all_good: 0x01,
    firm_fail: 0xFF
  )
end
