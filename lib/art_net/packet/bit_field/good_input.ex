defmodule ArtNet.Packet.BitField.GoodInput do
  @moduledoc """
  GoodInput bit field used by `ArtNet.Packet.ArtPollReply`.

  The packet contains one `GoodInput` value for each of the four reported
  ports. Each boolean describes the input state of that port.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:convert_sacn, :boolean, description: "Input is converting sACN to Art-Net.")
    field(:receive_errors, :boolean, offset: 1, description: "Receive errors have been detected.")
    field(:input_disabled, :boolean, description: "Input is disabled.")
    field(:dmx_text, :boolean, description: "DMX text packets have been received.")
    field(:dmx_sip, :boolean, description: "DMX SIP packets have been received.")
    field(:dmx_test_packet, :boolean, description: "DMX test packets have been received.")
    field(:data_received, :boolean, description: "Data has been received.")
  end
end
