defmodule ArtNet.Packet.ArtMedia do
  @moduledoc """
  Sends media-server data to a controller.

  This packet carries media information such as media type, page, and file
  identifiers for Art-Net media extensions.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler3, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler4, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:stream, {:integer, 8}, description: "Media stream identifier.")
    field(:command, {:integer, 8}, description: "Media command code.")
    field(:command_data1, {:integer, 8}, description: "First command-specific data byte.")
    field(:command_data2, {:integer, 8}, description: "Second command-specific data byte.")
    field(:command_data3, {:integer, 8}, description: "Third command-specific data byte.")
    field(:packs, [{:integer, 8}], description: "Additional media command data bytes.")
  end

  def validate(%{packs: packs}) when length(packs) <= 240 * 6 and rem(length(packs), 6) == 0,
    do: :ok

  def validate(_), do: {:error, "Packs must contain up to 240 6-byte entries"}
end
