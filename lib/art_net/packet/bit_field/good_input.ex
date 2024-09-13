defmodule ArtNet.Packet.BitField.GoodInput do
  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:receive_errors, :boolean, offset: 2)
    field(:input_disabled, :boolean)
    field(:dmx_text, :boolean)
    field(:dmx_sip, :boolean)
    field(:dmx_test_packet, :boolean)
    field(:data_received, :boolean)
  end
end
