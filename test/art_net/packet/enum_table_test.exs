defmodule ArtNet.Packet.EnumTableTest do
  use ExUnit.Case, async: true

  doctest ArtNet.Packet.EnumTable

  describe "@before_compile" do
    test "raises when enum value does not fit in bit_size" do
      module = unique_module_name()

      assert_raise ArgumentError,
                   ~r/value 4 \(0b100\) does not fit in bit_size 2; expected 0 \(0b00\)\.\.3 \(0b11\)/,
                   fn ->
                     Code.compile_string("""
                     defmodule #{module} do
                       use ArtNet.Packet.EnumTable

                       defenumtable([bit_size: 2],
                         valid: 0b11,
                         invalid: 0b100
                       )
                     end
                     """)
                   end
    end
  end

  defp unique_module_name do
    "ArtNet.Packet.EnumTableTest.Invalid#{System.unique_integer([:positive])}"
  end
end
