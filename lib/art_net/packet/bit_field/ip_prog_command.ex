defmodule ArtNet.Packet.BitField.IpProgCommand do
  @moduledoc """
  Command bit field used by `ArtNet.Packet.ArtIpProg`.

  Each boolean selects an IP programming action requested from the node.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:program_port, :boolean, default: false, description: "Program the port field.")

    field(:program_subnet_mask, :boolean,
      default: false,
      description: "Program the subnet mask."
    )

    field(:program_ip, :boolean, default: false, description: "Program the IP address.")

    field(:reset_to_default, :boolean,
      default: false,
      description: "Reset network settings to defaults."
    )

    field(:program_default_gateway, :boolean,
      default: false,
      description: "Program the default gateway."
    )

    field(:dhcp, :boolean, offset: 1, default: false, description: "Enable DHCP.")

    field(:enable_programming, :boolean,
      default: false,
      description: "Enable programming for the requested fields."
    )
  end
end
