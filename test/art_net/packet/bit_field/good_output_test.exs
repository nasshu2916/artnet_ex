defmodule ArtNet.Packet.BitField.GoodOutputTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.BitField.GoodOutput

  test "decode/encode" do
    [
      {%GoodOutput{
         convert_sacn: false,
         marge_ltp_mode: false,
         output_short: false,
         merging: false,
         dmx_test_packet: false,
         dmx_sip: false,
         dmx_text: false,
         output_data: false
       }, 0b00000000},
      {%GoodOutput{
         convert_sacn: true,
         marge_ltp_mode: false,
         output_short: false,
         merging: false,
         dmx_test_packet: false,
         dmx_sip: false,
         dmx_text: false,
         output_data: false
       }, 0b00000001},
      {%GoodOutput{
         convert_sacn: false,
         marge_ltp_mode: true,
         output_short: false,
         merging: false,
         dmx_test_packet: false,
         dmx_sip: true,
         dmx_text: false,
         output_data: true
       }, 0b10100010}
    ]
    |> Enum.each(fn {bit_field, data} ->
      assert GoodOutput.encode(bit_field) == {:ok, data}
      assert GoodOutput.decode(data) == {:ok, bit_field}
    end)
  end
end
