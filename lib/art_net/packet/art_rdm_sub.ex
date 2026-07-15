defmodule ArtNet.Packet.ArtRdmSub do
  @moduledoc """
  Carries compressed RDM sub-device data.

  This packet is used for RDM sub-device communication with command class and
  parameter metadata included in the payload.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:rdm_version, {:integer, 8}, default: 1, description: "RDM protocol version.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:uid, {:binary, 6}, description: "RDM responder UID.")
    field(:spare1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")

    field(:command_class, {:enum_table, EnumTable.RdmCommandClass},
      description: "RDM command class."
    )

    field(:parameter_id, {:integer, 16}, description: "RDM parameter identifier.")
    field(:sub_device, {:integer, 16}, description: "RDM sub-device identifier.")
    field(:sub_count, {:integer, 16}, description: "Number of sub-device data entries.")

    field(:spare, {:binary, 4},
      default: <<0::size(32)>>,
      description: "Reserved bytes, transmitted as zero."
    )

    field(:data, [{:integer, 16}], description: "RDM sub-device data values.")
  end

  @impl ArtNet.Packet.Schema
  def validate(%{sub_count: 0}), do: {:error, "SubCount must be greater than zero"}

  def validate(%{command_class: command_class})
      when command_class not in [:get_command, :get_response, :set_command, :set_response],
      do: {:error, "CommandClass must be Get, Set, GetResponse, or SetResponse"}

  def validate(%{command_class: command_class, sub_count: sub_count, data: data}) do
    expected_length =
      case command_class do
        :set_command -> sub_count
        :get_response -> sub_count
        :get_command -> 0
        :set_response -> 0
      end

    if length(data) == expected_length do
      :ok
    else
      {:error, "Data length does not match the command class and sub_count fields"}
    end
  end
end
