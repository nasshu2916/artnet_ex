defmodule ArtNet.Packet.ArtPoll do
  use ArtNet.Packet.Schema

  alias ArtNet.Packet.{BitField, EnumTable}

  defpacket do
    field(:talk_to_me, {:bit_field, BitField.TalkToMe})
    field(:priority, {:enum_table, EnumTable.Priority}, default: :dp_all)
    field(:target_port_address_top, {:integer, 16}, default: 0)
    field(:target_port_address_bottom, {:integer, 16}, default: 0)
    field(:esta_manufacturer, {:integer, 16}, default: 0)
    field(:oem, {:integer, 16}, default: 0)
  end

  @impl ArtNet.Packet.Schema
  def pre_decode(body), do: ArtNet.Packet.Schema.pad_binary(body, 10)
end
