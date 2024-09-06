defmodule ArtNet.Packet.ArtPoll do
  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket op_code: 0x2000 do
    field(:talk_to_me, :uint8, default: 0)
    field(:priority, {:enum_table, EnumTable.Priority}, default: :dp_all)
  end
end
