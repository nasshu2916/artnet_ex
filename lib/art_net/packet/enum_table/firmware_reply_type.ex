defmodule ArtNet.Packet.EnumTable.FirmwareReplyType do
  @moduledoc """
  Firmware transfer reply values used by `ArtNet.Packet.ArtFirmwareReply`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    firm_block_good: {0x00, description: "Current block was accepted."},
    firm_all_good: {0x01, description: "Complete transfer was accepted."},
    firm_fail: {0xFF, description: "Transfer failed."}
  )
end
