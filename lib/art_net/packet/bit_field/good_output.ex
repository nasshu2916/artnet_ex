defmodule ArtNet.Packet.BitField.GoodOutput do
  @moduledoc """
  GoodOutput bit field used by `ArtNet.Packet.ArtPollReply`.

  The packet contains one `GoodOutput` value for each of the four reported
  ports. Each boolean describes the output state of that port.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:convert_sacn, :boolean, description: "Output is converting Art-Net to sACN.")
    field(:merge_ltp_mode, :boolean, description: "Port is merging in LTP mode.")
    field(:output_short, :boolean, description: "Output short condition has been detected.")
    field(:merging, :boolean, description: "Port is currently merging data.")
    field(:dmx_test_packet, :boolean, description: "DMX test packets are being output.")
    field(:dmx_sip, :boolean, description: "DMX SIP packets are being output.")
    field(:dmx_text, :boolean, description: "DMX text packets are being output.")
    field(:output_data, :boolean, description: "Output data is being transmitted.")
  end
end
