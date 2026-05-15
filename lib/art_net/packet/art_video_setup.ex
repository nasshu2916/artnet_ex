defmodule ArtNet.Packet.ArtVideoSetup do
  use ArtNet.Packet.Schema

  defpacket do
    field(:filler, {:binary, 4}, default: <<0::size(32)>>)
    field(:control, {:integer, 8})
    field(:font_height, {:integer, 8})
    field(:first_font, {:integer, 8})
    field(:last_font, {:integer, 8})
    field(:windows_font_name, {:string, 64})
    field(:font_data, [{:integer, 8}])
  end

  def validate(%{font_height: font_height, last_font: last_font, font_data: font_data})
      when font_height in 8..16 and length(font_data) == font_height * last_font,
      do: :ok

  def validate(_), do: {:error, "Font data length must match font_height * last_font"}
end
