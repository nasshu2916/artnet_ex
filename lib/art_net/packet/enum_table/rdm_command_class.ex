defmodule ArtNet.Packet.EnumTable.RdmCommandClass do
  @moduledoc """
  RDM command class values used by `ArtNet.Packet.ArtRdmSub`.

    * `:discovery_command` - RDM discovery command.
    * `:discovery_command_response` - response to a discovery command.
    * `:get_command` - RDM get command.
    * `:get_response` - response to a get command.
    * `:set_command` - RDM set command.
    * `:set_response` - response to a set command.
  """

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
