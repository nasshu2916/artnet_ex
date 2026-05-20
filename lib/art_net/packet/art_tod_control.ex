defmodule ArtNet.Packet.ArtTodControl do
  @moduledoc """
  Sends RDM discovery control commands to a node.

  This packet controls behavior such as flushing or updating the node's Table
  of Devices.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:spare, {:binary, 7}, default: <<0::size(56)>>)
    field(:net, {:integer, 8}, default: 0)
    field(:command, {:enum_table, EnumTable.TodControlCommand}, default: :atc_none)
    field(:address, {:integer, 8})
  end
end
