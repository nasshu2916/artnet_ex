defmodule ArtNet.Packet.BitField.Status2Test do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.BitField.Status2

  test "decode/encode" do
    [
      {%Status2{
         support_browser: false,
         dhcp: false,
         dhcp_capable: false,
         port_15bit: false,
         can_switch: false,
         squawking: false,
         switch_output_style: false,
         control_rdm: false
       }, 0b00000000},
      {%Status2{
         support_browser: true,
         dhcp: false,
         dhcp_capable: false,
         port_15bit: true,
         can_switch: false,
         squawking: false,
         switch_output_style: true,
         control_rdm: false
       }, 0b01001001},
      {%Status2{
         support_browser: false,
         dhcp: true,
         dhcp_capable: true,
         port_15bit: true,
         can_switch: true,
         squawking: true,
         switch_output_style: false,
         control_rdm: true
       }, 0b10111110}
    ]
    |> Enum.each(fn {bit_field, data} ->
      assert Status2.encode(bit_field) == {:ok, data}
      assert Status2.decode(data) == {:ok, bit_field}
    end)
  end
end
