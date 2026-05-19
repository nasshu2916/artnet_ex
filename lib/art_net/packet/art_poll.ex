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
  def pre_decode(body), do: ArtNet.Misc.pad_binary(body, 10, 2)

  @impl ArtNet.Packet.Schema
  def validate_encode(%__MODULE__{} = packet) do
    with :ok <- validate_port_address(packet.target_port_address_top, :target_port_address_top),
         :ok <-
           validate_port_address(packet.target_port_address_bottom, :target_port_address_bottom) do
      :ok
    end
  end

  defp validate_port_address(value, _field)
       when is_integer(value) and value >= 0 and value <= 0x7FFF do
    :ok
  end

  defp validate_port_address(_value, field) do
    {:error, "#{field} must be a 15-bit Port-Address"}
  end
end
