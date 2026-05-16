defmodule ArtNet.Packet.BitField.IpProgCommand do
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
