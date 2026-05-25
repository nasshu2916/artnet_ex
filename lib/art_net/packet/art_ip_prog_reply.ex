defmodule ArtNet.Packet.ArtIpProgReply do
  @moduledoc """
  Acknowledges receipt of an `ArtNet.Packet.ArtIpProg` packet.

  Nodes use this packet to report their programmed IP address, subnet mask,
  gateway, and DHCP status.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.BitField

  defpacket do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler3, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler4, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:program_ip, {:binary, 4}, description: "Current or programmed IPv4 address.")
    field(:program_subnet_mask, {:binary, 4}, description: "Current or programmed subnet mask.")
    field(:program_port, {:integer, 16}, description: "Current or programmed UDP port.")

    field(:status, {:bit_field, BitField.IpProgStatus},
      description: "IP programming status flags."
    )

    field(:spare2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")

    field(:program_default_gateway, {:binary, 4},
      description: "Current or programmed default gateway."
    )

    field(:spare, {:binary, 2},
      default: <<0::size(16)>>,
      description: "Reserved bytes, transmitted as zero."
    )
  end
end
