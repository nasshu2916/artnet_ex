defmodule ArtNet.Packet.BitField.GoodInputTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.BitField.GoodInput

  test "decode/encode" do
    [
      {%GoodInput{
         receive_errors: false,
         input_disabled: false,
         dmx_text: false,
         dmx_sip: false,
         dmx_test_packet: false,
         data_received: false
       }, 0b00000000},
      {%GoodInput{
         receive_errors: true,
         input_disabled: false,
         dmx_text: false,
         dmx_sip: false,
         dmx_test_packet: false,
         data_received: false
       }, 0b00000100},
      {%GoodInput{
         receive_errors: false,
         input_disabled: true,
         dmx_text: false,
         dmx_sip: false,
         dmx_test_packet: false,
         data_received: true
       }, 0b10001000}
    ]
    |> Enum.each(fn {bit_field, data} ->
      assert GoodInput.encode(bit_field) == {:ok, data}
      assert GoodInput.decode(data) == {:ok, bit_field}
    end)
  end
end
