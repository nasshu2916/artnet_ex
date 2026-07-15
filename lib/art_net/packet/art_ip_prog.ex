defmodule ArtNet.Packet.ArtIpProg do
  @moduledoc """
  Reprograms a node's IP addressing configuration.

  This packet can request changes to IP address, subnet mask, default gateway,
  DHCP state, and related programming flags.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.BitField

  defpacket op_code: {:op_ip_prog, 0xF800} do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")

    field(:command, {:bit_field, BitField.IpProgCommand},
      description: "IP programming command flags."
    )

    field(:filler4, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:program_ip, {:binary, 4}, description: "IPv4 address to program into the node.")

    field(:program_subnet_mask, {:binary, 4},
      description: "Subnet mask to program into the node."
    )

    field(:program_port, {:integer, 16}, description: "UDP port to program into the node.")

    field(:program_default_gateway, {:binary, 4},
      description: "Default gateway IPv4 address to program."
    )

    field(:spare, {:binary, 4},
      default: <<0::size(32)>>,
      description: "Reserved bytes, transmitted as zero."
    )
  end
end
