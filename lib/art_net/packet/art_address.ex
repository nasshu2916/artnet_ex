defmodule ArtNet.Packet.ArtAddress do
  @moduledoc """
  Sends remote programming information to a node.

  This packet can change node addressing, short/long names, merge behavior,
  port direction, indicator state, and related node configuration.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:net_switch, {:integer, 8}, default: 0)
    field(:bind_index, {:integer, 8}, default: 1)
    field(:port_name, {:string, 18})
    field(:long_name, {:string, 64})
    field(:sw_in, [{:integer, 8}], length: 4)
    field(:sw_out, [{:integer, 8}], length: 4)
    field(:sub_switch, {:integer, 8}, default: 0)
    field(:acn_priority, {:integer, 8}, default: 0)
    field(:command, {:enum_table, EnumTable.AddressCommand}, default: :ac_none)
  end
end
