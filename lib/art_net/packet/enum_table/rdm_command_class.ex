defmodule ArtNet.Packet.EnumTable.RdmCommandClass do
  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    discovery_command: 0x10,
    discovery_command_response: 0x11,
    get_command: 0x20,
    get_response: 0x21,
    set_command: 0x30,
    set_response: 0x31
  )
end
