defmodule ArtNet.Packet.EnumTable.FirmwareMasterType do
  @moduledoc """
  Firmware transfer block types used by `ArtNet.Packet.ArtFirmwareMaster`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    firm_first: {0x00, description: "First firmware block."},
    firm_cont: {0x01, description: "Continuation firmware block."},
    firm_last: {0x02, description: "Final firmware block."},
    ubea_first: {0x03, description: "First UBEA block."},
    ubea_cont: {0x04, description: "Continuation UBEA block."},
    ubea_last: {0x05, description: "Final UBEA block."}
  )
end
