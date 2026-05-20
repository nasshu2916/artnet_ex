defmodule ArtNet.Packet.EnumTableTest do
  use ExUnit.Case, async: true

  doctest ArtNet.Packet.EnumTable

  describe "generated docs" do
    test "documents generated enum table functions" do
      assert {:docs_v1, _, :elixir, "text/markdown", %{"en" => moduledoc}, _, docs} =
               Code.fetch_docs(ArtNet.Packet.EnumTable.Priority)

      assert moduledoc =~ "## Values"
      assert moduledoc =~ "| Atom | Value |"
      assert moduledoc =~ "| `dp_all` | `0x0 / 0b00000000` |"
      assert moduledoc =~ "| `dp_volatile` | `0xF0 / 0b11110000` |"

      docs_by_function =
        Map.new(docs, fn
          {{:function, name, arity}, _, signatures, %{"en" => doc}, _} ->
            {{name, arity}, {signatures, doc}}

          {{:function, name, arity}, _, signatures, doc, _} ->
            {{name, arity}, {signatures, doc}}

          {kind, _, signatures, doc, _} ->
            {kind, {signatures, doc}}
        end)

      assert {["bit_size()"], bit_size_doc} = docs_by_function[{:bit_size, 0}]
      assert bit_size_doc =~ "Returns the number of bits"

      assert {["dp_all()"], dp_all_doc} = docs_by_function[{:dp_all, 0}]
      assert dp_all_doc =~ "Returns the integer code for `:dp_all`"

      assert {["to_code(value)"], to_code_doc} = docs_by_function[{:to_code, 1}]
      assert to_code_doc =~ "Converts an enum atom"

      assert {["to_atom(code)"], to_atom_doc} = docs_by_function[{:to_atom, 1}]
      assert to_atom_doc =~ "Converts an integer code"
    end
  end

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
