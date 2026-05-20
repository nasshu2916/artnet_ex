defmodule ArtNet.Packet.ArtCommand do
  use ArtNet.Packet.Schema

  defpacket do
    field(:esta_manufacturer, {:integer, 16})
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
