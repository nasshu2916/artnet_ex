defmodule ArtNet.Packet.ArtVideoPalette do
  @moduledoc """
  Sends color palette setup information for extended video features.

  The packet carries red, green, and blue palette values used by Art-Net video
  data.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:colour_red, [{:integer, 8}], length: 17)
    field(:colour_green, [{:integer, 8}], length: 17)
    field(:colour_blue, [{:integer, 8}], length: 17)
  end
end
