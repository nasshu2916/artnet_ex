defmodule ArtNet.Packet.BitField.GoodInput do
  @moduledoc """
  GoodInput bit field used by `ArtNet.Packet.ArtPollReply`.

  The packet contains one `GoodInput` value for each of the four reported
  ports. Each boolean describes the input state of that port.

    * `:convert_sacn` - input is converting sACN to Art-Net.
    * `:receive_errors` - receive errors have been detected.
    * `:input_disabled` - input is disabled.
    * `:dmx_text` - DMX text packets have been received.
    * `:dmx_sip` - DMX SIP packets have been received.
    * `:dmx_test_packet` - DMX test packets have been received.
    * `:data_received` - data has been received.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:convert_sacn, :boolean)
    field(:receive_errors, :boolean, offset: 1)
    field(:input_disabled, :boolean)
    field(:dmx_text, :boolean)
    field(:dmx_sip, :boolean)
    field(:dmx_test_packet, :boolean)
    field(:data_received, :boolean)
  end
end
