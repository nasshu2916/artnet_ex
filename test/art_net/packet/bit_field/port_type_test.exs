defmodule ArtNet.Packet.BitField.PortTypeTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.BitField.PortType

  test "decode/encode" do
    [
      {%PortType{
         port_type: :dmx512,
         input: false,
         output: false
       }, 0b00000000},
      {%PortType{
         port_type: :dmx512,
         input: true,
         output: false
       }, 0b01000000},
      {%PortType{
         port_type: :art_net,
         input: false,
         output: true
       }, 0b10000101}
    ]
    |> Enum.each(fn {bit_field, data} ->
      assert PortType.encode(bit_field) == {:ok, data}
      assert PortType.decode(data) == {:ok, bit_field}
    end)
  end
end
