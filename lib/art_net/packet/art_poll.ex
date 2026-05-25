defmodule ArtNet.Packet.ArtPoll do
  @moduledoc """
  Discovers Art-Net nodes on the network.

  Controllers broadcast this packet to ask nodes to identify themselves. Nodes
  respond with `ArtNet.Packet.ArtPollReply`.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.{BitField, EnumTable}

  defpacket do
    field(:talk_to_me, {:bit_field, BitField.TalkToMe}, description: "Poll reply behavior flags.")

    field(:priority, {:enum_table, EnumTable.Priority},
      default: :dp_all,
      description: "Minimum diagnostic priority requested from nodes."
    )

    field(:target_port_address_top, {:integer, 16},
      default: 0,
      description: "Upper bound of the targeted Port-Address range."
    )

    field(:target_port_address_bottom, {:integer, 16},
      default: 0,
      description: "Lower bound of the targeted Port-Address range."
    )

    field(:esta_manufacturer, {:integer, 16},
      default: 0,
      description: "ESTA manufacturer code filter for targeted polling."
    )

    field(:oem, {:integer, 16},
      default: 0,
      description: "OEM code filter for targeted polling."
    )
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
