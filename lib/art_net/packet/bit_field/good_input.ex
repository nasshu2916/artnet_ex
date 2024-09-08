defmodule ArtNet.Packet.BitField.GoodInput do
  use ArtNet.Packet.BitField

  defbitfield size: 8, offset: 2 do
    field(:recive_errors, :boolean)
    field(:input_disabled, :boolean)
    field(:dmx_text, :boolean)
    field(:dmx_sip, :boolean)
    field(:dmx_test_packet, :boolean)
    field(:data_received, :boolean)
  end
end
