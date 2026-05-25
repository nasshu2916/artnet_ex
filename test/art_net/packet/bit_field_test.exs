defmodule ArtNet.Packet.BitFieldTest do
  use ExUnit.Case, async: true

  doctest ArtNet.Packet.BitField

  describe "generated docs" do
    test "documents generated bit-field schema layout" do
      assert {:docs_v1, _, :elixir, "text/markdown", %{"en" => moduledoc}, _, docs} =
               Code.fetch_docs(ArtNet.Packet.BitField.Status3)

      assert moduledoc =~ "## Bit size"
      assert moduledoc =~ "This bit field is encoded in `8` bits."

      docs_by_function =
        Map.new(docs, fn
          {{:function, name, arity}, _, signatures, %{"en" => doc}, _} ->
            {{name, arity}, {signatures, doc}}

          {{:function, name, arity}, _, signatures, doc, _} ->
            {{name, arity}, {signatures, doc}}

          {kind, _, signatures, doc, _} ->
            {kind, {signatures, doc}}
        end)

      assert {["bit_field_schema()"], schema_doc} = docs_by_function[{:bit_field_schema, 0}]
      assert schema_doc =~ "| Field | Description | Bits | Default | Value |"

      assert schema_doc =~
               "| `background_discovery_control` | Background discovery can be controlled. | `0` | `false` |"

      assert schema_doc =~ "`boolean` flag"

      assert schema_doc =~
               "| `failsafe_state` | Active failsafe state reported by `ArtNet.Packet.EnumTable.FailsafeState`. | `6..7` | `:hold_last` |"

      assert schema_doc =~ "`ArtNet.Packet.EnumTable.FailsafeState` enum (`2` bits)"

      assert {["bit_size()"], bit_size_doc} = docs_by_function[{:bit_size, 0}]
      assert bit_size_doc =~ "This bit field is encoded in `8` bits."

      assert {["decode(value)"], _decode_doc} = docs_by_function[{:decode, 1}]
      assert {["encode(struct)"], _encode_doc} = docs_by_function[{:encode, 1}]
    end
  end

  describe "field/3" do
    test "raises when bit-field description is not a string" do
      module = unique_module_name()

      assert_raise ArgumentError,
                   "the description option for field :invalid must be a string, got: :bad",
                   fn ->
                     Code.compile_string("""
                     defmodule #{module} do
                       use ArtNet.Packet.BitField

                       defbitfield bit_size: 1 do
                         field(:invalid, :boolean, description: :bad)
                       end
                     end
                     """)
                   end
    end
  end

  defp unique_module_name do
    "ArtNet.Packet.BitFieldTest.Invalid#{System.unique_integer([:positive])}"
  end
end
