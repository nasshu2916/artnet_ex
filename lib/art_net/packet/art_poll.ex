defmodule ArtNet.Packet.ArtPoll do
  use ArtNet.Packet.Schema

  alias ArtNet.Packet.{BitField, EnumTable}

  @body_size 2
  @filler_size 8

  defpacket do
    field(:talk_to_me, {:bit_field, BitField.TalkToMe})
    field(:priority, {:enum_table, EnumTable.Priority}, default: :dp_all)
  end

  @impl ArtNet.Packet.Schema
  def pre_decode(<<body::binary-size(@body_size), 0::size(@filler_size * 8)>>), do: body

  def pre_decode(body), do: body
end
