defmodule ArtNet.Packet.ArtIpProg do
  @moduledoc """
  Reprograms a node's IP addressing configuration.

  This packet can request changes to IP address, subnet mask, default gateway,
  DHCP state, and related programming flags.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.BitField

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:command, {:bit_field, BitField.IpProgCommand})
    field(:filler4, {:integer, 8}, default: 0)
    field(:program_ip, {:binary, 4})
    field(:program_subnet_mask, {:binary, 4})
    field(:program_port, {:integer, 16})
    field(:program_default_gateway, {:binary, 4})
    field(:spare, {:binary, 4}, default: <<0::size(32)>>)
  end
end
