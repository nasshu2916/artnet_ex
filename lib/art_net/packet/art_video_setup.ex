defmodule ArtNet.Packet.ArtVideoSetup do
  @moduledoc """
  Sends video screen setup information for extended video features.

  The packet configures screen control, font, window, and cursor parameters.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler, {:binary, 4},
      default: <<0::size(32)>>,
      description: "Reserved bytes, transmitted as zero."
    )

    field(:control, {:integer, 8}, description: "Video setup control flags.")
    field(:font_height, {:integer, 8}, description: "Font glyph height in pixels.")

    field(:first_font, {:integer, 8},
      description: "First font glyph index included in the packet."
    )

    field(:last_font, {:integer, 8}, description: "Last font glyph index included in the packet.")

    field(:windows_font_name, {:string, 64},
      description: "Windows font name for the video setup."
    )

    field(:font_data, [{:integer, 8}], description: "Packed font glyph data bytes.")
  end

  def validate(%{font_height: font_height, last_font: last_font, font_data: font_data})
      when font_height in 8..16 and length(font_data) == font_height * last_font,
      do: :ok

  def validate(_), do: {:error, "Font data length must match font_height * last_font"}
end
