defmodule ArtNet.Packet.ArtVideoData do
  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:position_x, {:integer, 8})
    field(:position_y, {:integer, 8})
    field(:length_x, {:integer, 8})
    field(:length_y, {:integer, 8})
    field(:data, [{:integer, 8}])
  end

  def validate(%{length_x: length_x, length_y: length_y, data: data})
      when length(data) == length_x * length_y * 2,
      do: :ok

  def validate(_), do: {:error, "Data length must match length_x * length_y * 2"}
end
