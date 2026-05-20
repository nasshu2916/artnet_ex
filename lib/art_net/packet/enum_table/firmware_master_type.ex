defmodule ArtNet.Packet.EnumTable.FirmwareMasterType do
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
