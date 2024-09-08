defmodule ArtNet.Packet.BitField.GoodOutput do
  use ArtNet.Packet.BitField

  defbitfield size: 8 do
    field(:convert_sacn, :boolean)
    field(:marge_ltp_mode, :boolean)
    field(:output_short, :boolean)
    field(:marging, :boolean)
    field(:dmx_test_packet, :boolean)
    field(:dmx_sip, :boolean)
    field(:dmx_text, :boolean)
    field(:output_data, :boolean)
  end
end
