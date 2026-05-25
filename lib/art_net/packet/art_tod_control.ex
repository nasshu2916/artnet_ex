defmodule ArtNet.Packet.ArtTodControl do
  @moduledoc """
  Sends RDM discovery control commands to a node.

  This packet controls behavior such as flushing or updating the node's Table
  of Devices.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")

    field(:spare, {:binary, 7},
      default: <<0::size(56)>>,
      description: "Reserved bytes, transmitted as zero."
    )

    field(:net, {:integer, 8},
      default: 0,
      description: "Bits 8-14 of the 15-bit Port-Address."
    )

    field(:command, {:enum_table, EnumTable.TodControlCommand},
      default: :atc_none,
      description: "Table-of-devices control command."
    )

    field(:address, {:integer, 8}, description: "Low byte of the target Port-Address.")
  end
end
