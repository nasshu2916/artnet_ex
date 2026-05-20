defmodule ArtNet.Packet.EnumTable.FirmwareMasterType do
  @moduledoc """
  Firmware transfer block types used by `ArtNet.Packet.ArtFirmwareMaster`.

    * `:firm_first` - first firmware block.
    * `:firm_cont` - continuation firmware block.
    * `:firm_last` - final firmware block.
    * `:ubea_first` - first UBEA block.
    * `:ubea_cont` - continuation UBEA block.
    * `:ubea_last` - final UBEA block.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    firm_first: 0x00,
    firm_cont: 0x01,
    firm_last: 0x02,
    ubea_first: 0x03,
    ubea_cont: 0x04,
    ubea_last: 0x05
  )
end
