defmodule ArtNet.Packet.ArtVideoPalette do
  @moduledoc """
  Sends color palette setup information for extended video features.

  The packet carries red, green, and blue palette values used by Art-Net video
  data.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")

    field(:colour_red, [{:integer, 8}],
      length: 17,
      description: "Red components of the video colour palette."
    )

    field(:colour_green, [{:integer, 8}],
      length: 17,
      description: "Green components of the video colour palette."
    )

    field(:colour_blue, [{:integer, 8}],
      length: 17,
      description: "Blue components of the video colour palette."
    )
  end
end
