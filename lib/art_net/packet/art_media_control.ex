defmodule ArtNet.Packet.ArtMediaControl do
  @moduledoc """
  Sends media control commands to a media server.

  This packet carries control values such as media type, page, file, and
  playback-related parameters.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: {:op_media_control, 0x9200} do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler3, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler4, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:stream, {:integer, 8}, description: "Media stream identifier.")
    field(:control_command, {:integer, 8}, description: "Media control command code.")

    field(:command_data1, {:integer, 8},
      default: 0,
      description: "First control command data byte."
    )

    field(:command_data2, {:integer, 8},
      default: 0,
      description: "Second control command data byte."
    )

    field(:command_data3, {:integer, 8},
      default: 0,
      description: "Third control command data byte."
    )

    field(:command_data4, {:integer, 8},
      default: 0,
      description: "Fourth control command data byte."
    )

    field(:command_data5, {:integer, 8},
      default: 0,
      description: "Fifth control command data byte."
    )

    field(:command_data6, {:integer, 8},
      default: 0,
      description: "Sixth control command data byte."
    )
  end
end
