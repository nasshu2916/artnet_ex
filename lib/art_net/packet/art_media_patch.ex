defmodule ArtNet.Packet.ArtMediaPatch do
  @moduledoc """
  Sends media patch information to a media server.

  Controllers use this packet to map media server layers and outputs for
  Art-Net media extensions.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:filler3, {:integer, 8}, default: 0)
    field(:filler4, {:integer, 8}, default: 0)
    field(:stream, {:integer, 8})
    field(:patch_command, {:integer, 8})
    field(:virtual_delta_x, {:integer, 16})
    field(:virtual_delta_y, {:integer, 16})
    field(:coordinate_count, {:integer, 16})
    field(:aperture, {:integer, 8})
    field(:diameter, {:integer, 8})
    field(:coordinates, [{:integer, 8}])
  end

  def validate(%{coordinates: coordinates})
      when length(coordinates) <= 240 * 6 and rem(length(coordinates), 6) == 0,
      do: :ok

  def validate(_), do: {:error, "Coordinates must contain up to 240 6-byte entries"}
end
