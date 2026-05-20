defmodule ArtNet.Packet.BitField.GoodOutput do
  @moduledoc """
  GoodOutput bit field used by `ArtNet.Packet.ArtPollReply`.

  The packet contains one `GoodOutput` value for each of the four reported
  ports. Each boolean describes the output state of that port.

    * `:convert_sacn` - output is converting Art-Net to sACN.
    * `:merge_ltp_mode` - port is merging in LTP mode.
    * `:output_short` - output short condition has been detected.
    * `:merging` - port is currently merging data.
    * `:dmx_test_packet` - DMX test packets are being output.
    * `:dmx_sip` - DMX SIP packets are being output.
    * `:dmx_text` - DMX text packets are being output.
    * `:output_data` - output data is being transmitted.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:convert_sacn, :boolean)
    field(:merge_ltp_mode, :boolean)
    field(:output_short, :boolean)
    field(:merging, :boolean)
    field(:dmx_test_packet, :boolean)
    field(:dmx_sip, :boolean)
    field(:dmx_text, :boolean)
    field(:output_data, :boolean)
  end
end
