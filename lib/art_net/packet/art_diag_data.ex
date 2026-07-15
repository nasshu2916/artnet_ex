defmodule ArtNet.Packet.ArtDiagData do
  @moduledoc """
  Carries diagnostic and data logging text from a node.

  The `priority` field classifies the diagnostic severity, and `data` contains
  the diagnostic payload bytes.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket op_code: {:op_diag_data, 0x2300} do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:priority, {:enum_table, EnumTable.Priority}, description: "Diagnostic priority level.")

    field(:logical_port, {:integer, 8},
      default: 0,
      description: "Logical port associated with the diagnostic data."
    )

    field(:filler3, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:length, {:integer, 16}, description: "Number of diagnostic data bytes.")
    field(:data, [{:integer, 8}], description: "Diagnostic text or binary data bytes.")
  end

  @impl ArtNet.Packet.Schema
  def validate(%{length: length, data: data}) do
    cond do
      length != length(data) ->
        {:error, "Data length does not match the length field"}

      length > 512 ->
        {:error, "Data length must be 512 or less"}

      true ->
        :ok
    end
  end
end
