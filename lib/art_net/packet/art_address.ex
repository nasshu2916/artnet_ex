defmodule ArtNet.Packet.ArtAddress do
  @moduledoc """
  Sends remote programming information to a node.

  This packet can change node addressing, short/long names, merge behavior,
  port direction, indicator state, and related node configuration.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket op_code: 0x6000 do
    field(:net_switch, {:integer, 8},
      default: 0,
      description: "Top 7 bits of the node Net address."
    )

    field(:bind_index, {:integer, 8},
      default: 1,
      description: "Bind index of the node being configured."
    )

    field(:port_name, {:string, 18}, description: "Short name to assign to the node.")
    field(:long_name, {:string, 64}, description: "Long name to assign to the node.")

    field(:sw_in, [{:integer, 8}],
      length: 4,
      description: "Input Port-Address low byte values for each port."
    )

    field(:sw_out, [{:integer, 8}],
      length: 4,
      description: "Output Port-Address low byte values for each port."
    )

    field(:sub_switch, {:integer, 8},
      default: 0,
      description: "Sub-Net address shared by the node ports."
    )

    field(:acn_priority, {:integer, 8},
      default: 0,
      description: "sACN priority value to assign to the node."
    )

    field(:command, {:enum_table, EnumTable.AddressCommand},
      default: :ac_none,
      description: "Address programming command to execute."
    )
  end
end
