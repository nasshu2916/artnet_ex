defmodule ArtNet.Packet.ArtMediaPatch do
  @moduledoc """
  Sends media patch information to a media server.

  Controllers use this packet to map media server layers and outputs for
  Art-Net media extensions.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: {:op_media_patch, 0x9100} do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler3, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler4, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:stream, {:integer, 8}, description: "Media stream identifier.")
    field(:patch_command, {:integer, 8}, description: "Media patch command code.")
    field(:virtual_delta_x, {:integer, 16}, description: "Virtual X coordinate delta.")
    field(:virtual_delta_y, {:integer, 16}, description: "Virtual Y coordinate delta.")

    field(:coordinate_count, {:integer, 16},
      description: "Number of coordinate entries in the payload."
    )

    field(:aperture, {:integer, 8}, description: "Patch aperture value.")
    field(:diameter, {:integer, 8}, description: "Patch diameter value.")
    field(:coordinates, [{:integer, 8}], description: "Packed media patch coordinate data.")
  end

  def validate(%{coordinates: coordinates})
      when length(coordinates) <= 240 * 6 and rem(length(coordinates), 6) == 0,
      do: :ok

  def validate(_), do: {:error, "Coordinates must contain up to 240 6-byte entries"}
end
