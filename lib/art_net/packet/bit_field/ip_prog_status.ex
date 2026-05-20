defmodule ArtNet.Packet.BitField.IpProgStatus do
  @moduledoc """
  Status bit field used by `ArtNet.Packet.ArtIpProgReply`.

  This field reports IP programming status from a node.

    * `:dhcp_enabled` - DHCP is enabled on the node.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:dhcp_enabled, :boolean, offset: 6, default: false)
  end
end
