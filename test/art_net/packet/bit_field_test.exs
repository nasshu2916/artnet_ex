defmodule ArtNet.Packet.BitFieldTest do
  use ExUnit.Case, async: true

  doctest ArtNet.Packet.BitField

  describe "generated docs" do
    test "documents generated bit-field schema layout" do
      assert {:docs_v1, _, :elixir, "text/markdown", _, _, docs} =
               Code.fetch_docs(ArtNet.Packet.BitField.Status3)

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
      assert schema_doc =~ "| Field | Bits | Value | Default |"
      assert schema_doc =~ "| `background_discovery_control` | `0` |"
      assert schema_doc =~ "`boolean` flag"
      assert schema_doc =~ "| `failsafe_state` | `6..7` |"
      assert schema_doc =~ "`ArtNet.Packet.EnumTable.FailsafeState` enum (`2` bits)"
      assert schema_doc =~ "`:hold_last`"

      assert {["decode(value)"], _decode_doc} = docs_by_function[{:decode, 1}]
      assert {["encode(struct)"], _encode_doc} = docs_by_function[{:encode, 1}]
    end
  end
end
