defmodule ArtNet.Packet.ArtNzs do
  use ArtNet.Packet.Schema

  defpacket do
    field(:sequence, {:integer, 8}, default: 0)
    field(:start_code, {:integer, 8})
    field(:sub_universe, {:integer, 8}, default: 0)
    field(:net, {:integer, 8}, default: 0)
    field(:length, {:integer, 16})
    field(:data, [{:integer, 8}])
  end

  @impl ArtNet.Packet.Schema
  def validate(%{start_code: 0}), do: {:error, "Start code must be non-zero"}
  def validate(%{start_code: 0xCC}), do: {:error, "Start code must not be RDM"}

  def validate(%{length: data_length, data: data}) do
    cond do
      data_length != length(data) ->
        {:error, "Data length does not match the length field"}

      data_length > 512 ->
        {:error, "Data length must be 512 or less"}

      data_length < 1 ->
        {:error, "Data length must be at least 1"}

      true ->
        :ok
    end
  end
end
