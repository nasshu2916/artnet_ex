defmodule ArtNet.Packet.BitField.IpProgStatus do
  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:dhcp_enabled, :boolean, offset: 6, default: false)
  end
end
