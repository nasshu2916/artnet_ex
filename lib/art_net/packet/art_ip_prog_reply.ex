defmodule ArtNet.Packet.ArtIpProgReply do
  @moduledoc """
  Acknowledges receipt of an `ArtNet.Packet.ArtIpProg` packet.

  Nodes use this packet to report their programmed IP address, subnet mask,
  gateway, and DHCP status.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.BitField

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:filler3, {:integer, 8}, default: 0)
    field(:filler4, {:integer, 8}, default: 0)
    field(:program_ip, {:binary, 4})
    field(:program_subnet_mask, {:binary, 4})
    field(:program_port, {:integer, 16})
    field(:status, {:bit_field, BitField.IpProgStatus})
    field(:spare2, {:integer, 8}, default: 0)
    field(:program_default_gateway, {:binary, 4})
    field(:spare, {:binary, 2}, default: <<0::size(16)>>)
  end
end
