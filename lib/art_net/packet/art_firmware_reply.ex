defmodule ArtNet.Packet.ArtFirmwareReply do
  @moduledoc """
  Acknowledges receipt of firmware transfer packets.

  Nodes use this packet to report whether a firmware block, complete transfer,
  or transfer failure was detected.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")

    field(:type, {:enum_table, EnumTable.FirmwareReplyType},
      description: "Firmware transfer reply status."
    )

    field(:spare, {:binary, 21},
      default: <<0::size(168)>>,
      description: "Reserved bytes, transmitted as zero."
    )
  end
end
