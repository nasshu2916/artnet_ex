defmodule ArtNet.Packet.ArtDiagData do
  @moduledoc """
  Carries diagnostic and data logging text from a node.

  The `priority` field classifies the diagnostic severity, and `data` contains
  the diagnostic payload bytes.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:priority, {:enum_table, EnumTable.Priority})
    field(:logical_port, {:integer, 8}, default: 0)
    field(:filler3, {:integer, 8}, default: 0)
    field(:length, {:integer, 16})
    field(:data, [{:integer, 8}])
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
