defmodule ArtNet.Packet.ArtVideoData do
  @moduledoc """
  Sends display data for extended video features.

  The packet carries tile position, dimensions, and pixel data for an Art-Net
  video surface.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: {:op_video_data, 0xA040} do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:position_x, {:integer, 8}, description: "Horizontal tile position for the video data.")
    field(:position_y, {:integer, 8}, description: "Vertical tile position for the video data.")

    field(:length_x, {:integer, 8},
      description: "Horizontal pixel count represented by the data."
    )

    field(:length_y, {:integer, 8}, description: "Vertical pixel count represented by the data.")
    field(:data, [{:integer, 8}], description: "Packed video data bytes.")
  end

  def validate(%{length_x: length_x, length_y: length_y, data: data})
      when length(data) == length_x * length_y * 2,
      do: :ok

  def validate(_), do: {:error, "Data length must match length_x * length_y * 2"}
end
