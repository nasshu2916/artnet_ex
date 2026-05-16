defmodule ArtNet.Packet.ArtFirmwareReply do
  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:type, {:enum_table, EnumTable.FirmwareReplyType})
    field(:spare, {:binary, 21}, default: <<0::size(168)>>)
  end
end
