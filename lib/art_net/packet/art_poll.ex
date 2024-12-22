defmodule ArtNet.Packet.ArtPoll do
  use ArtNet.Packet.Schema

  alias ArtNet.Packet.{BitField, EnumTable}

  defpacket do
    field(:talk_to_me, {:bit_field, BitField.TalkToMe})
    field(:priority, {:enum_table, EnumTable.Priority}, default: :dp_all)
  end
end
