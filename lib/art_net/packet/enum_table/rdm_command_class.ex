defmodule ArtNet.Packet.EnumTable.RdmCommandClass do
  @moduledoc """
  RDM command class values used by `ArtNet.Packet.ArtRdmSub`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    discovery_command: {0x10, description: "RDM discovery command."},
    discovery_command_response: {0x11, description: "Response to a discovery command."},
    get_command: {0x20, description: "RDM get command."},
    get_response: {0x21, description: "Response to a get command."},
    set_command: {0x30, description: "RDM set command."},
    set_response: {0x31, description: "Response to a set command."}
  )
end
