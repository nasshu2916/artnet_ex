defmodule ArtNet.Packet.BitField.Status1Test do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.BitField.Status1

  test "decode/encode" do
    [
      {%Status1{
         ubea: false,
         rdm: false,
         boot_rom: false,
         port_address: :unknown,
         indicator: :unknown
       }, 0b00000000},
      {%Status1{
         ubea: true,
         rdm: false,
         boot_rom: false,
         port_address: :front,
         indicator: :normal
       }, 0b11010001},
      {%Status1{
         ubea: false,
         rdm: true,
         boot_rom: true,
         port_address: :unused,
         indicator: :locate
       }, 0b01110110}
    ]
    |> Enum.each(fn {bit_field, data} ->
      assert Status1.encode(bit_field) == {:ok, data}
      assert Status1.decode(data) == {:ok, bit_field}
    end)
  end
end
