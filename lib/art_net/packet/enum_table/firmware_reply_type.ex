defmodule ArtNet.Packet.EnumTable.FirmwareReplyType do
  @moduledoc """
  Firmware transfer reply values used by `ArtNet.Packet.ArtFirmwareReply`.

    * `:firm_block_good` - current block was accepted.
    * `:firm_all_good` - complete transfer was accepted.
    * `:firm_fail` - transfer failed.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    firm_block_good: 0x00,
    firm_all_good: 0x01,
    firm_fail: 0xFF
  )
end
