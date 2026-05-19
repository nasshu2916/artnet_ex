defmodule ArtNet.Packet.Schema.TypesTest do
  use ExUnit.Case

  alias ArtNet.Packet.Schema.Types

  doctest ArtNet.Packet.Schema.Types

  describe "type_for/1" do
    test "returns :integer for integer formats" do
      assert Types.type_for({:integer, 8}) == :integer
      assert Types.type_for({:integer, 16, :little_endian}) == :integer
    end

    test "returns :binary for binary format" do
      assert Types.type_for({:binary, 4}) == :binary
    end

    test "returns String.t for string format" do
      assert Types.type_for({:string, 18}) ==
               {{:., [], [{:__aliases__, [], [:String]}, :t]}, [], []}
    end

    test "returns type for enum_table format" do
      assert Types.type_for({:enum_table, MyEnum}) ==
               {{:., [], [{:__aliases__, [], [MyEnum]}, :type]}, [], []}
    end

    test "returns t for bit_field format" do
      assert Types.type_for({:bit_field, MyBitField}) ==
               {{:., [], [{:__aliases__, [], [MyBitField]}, :t]}, [], []}
    end

    test "returns list of types for list format" do
      assert Types.type_for([{:integer, 8}]) == [:integer]
    end
  end

  describe "bit_field_type_for/1" do
    test "returns :boolean for :boolean format" do
      assert Types.bit_field_type_for(:boolean) == :boolean
    end

    test "returns type for enum_table format" do
      assert Types.bit_field_type_for({:enum_table, MyEnum}) ==
               {{:., [], [{:__aliases__, [], [MyEnum]}, :type]}, [], []}
    end
  end
end
