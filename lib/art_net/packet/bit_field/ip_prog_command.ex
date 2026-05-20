defmodule ArtNet.Packet.BitField.IpProgCommand do
  @moduledoc """
  Command bit field used by `ArtNet.Packet.ArtIpProg`.

  Each boolean selects an IP programming action requested from the node.

    * `:program_port` - program the port field.
    * `:program_subnet_mask` - program the subnet mask.
    * `:program_ip` - program the IP address.
    * `:reset_to_default` - reset network settings to defaults.
    * `:program_default_gateway` - program the default gateway.
    * `:dhcp` - enable DHCP.
    * `:enable_programming` - enable programming for the requested fields.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:program_port, :boolean, default: false)
    field(:program_subnet_mask, :boolean, default: false)
    field(:program_ip, :boolean, default: false)
    field(:reset_to_default, :boolean, default: false)
    field(:program_default_gateway, :boolean, default: false)
    field(:dhcp, :boolean, offset: 1, default: false)
    field(:enable_programming, :boolean, default: false)
  end
end
