defmodule ArtNet.Packet.BitFieldTest do
  use ExUnit.Case, async: true

  doctest ArtNet.Packet.BitField

  alias ArtNet.Packet.BitField

  defmodule LimitedEnum do
    def bit_size, do: 1
    def to_atom(0), do: {:ok, :ready}
    def to_atom(_), do: :error
    def to_code(:ready), do: {:ok, 0}
    def to_code(_), do: :error
  end

  defmodule LimitedBitField do
    defstruct [:state]

    def bit_size, do: 1
    def bit_field_schema, do: [state: {{:enum_table, LimitedEnum}, {0, 1}}]
    def decode(value), do: BitField.decode(value, __MODULE__)
    def encode(value), do: BitField.encode(value, __MODULE__)
  end

  describe "generated docs" do
    test "documents generated bit-field schema layout" do
      assert {:docs_v1, _, :elixir, "text/markdown", %{"en" => moduledoc}, _, docs} =
               Code.fetch_docs(ArtNet.Packet.BitField.Status3)

      assert moduledoc =~ "## Bit size"
      assert moduledoc =~ "This bit field is encoded in `8` bits."
      assert moduledoc =~ "## Bit layout"
      assert moduledoc =~ "| Field | Description | Bits | Default | Value |"

      assert moduledoc =~
               "| `background_discovery_control` | Background discovery can be controlled. | `0` | `false` |"

      assert moduledoc =~ "`boolean` flag"

      assert moduledoc =~
               "| `failsafe_state` | Active failsafe state reported by `ArtNet.Packet.EnumTable.FailsafeState`. | `6..7` | `:hold_last` |"

      assert moduledoc =~ "`ArtNet.Packet.EnumTable.FailsafeState` enum (`2` bits)"

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
      assert schema_doc =~ "Returns the bit-field schema in declaration order."
      refute schema_doc =~ "## Bit layout"
      refute schema_doc =~ "| Field | Description | Bits | Default | Value |"

      assert {["bit_size()"], bit_size_doc} = docs_by_function[{:bit_size, 0}]
      assert bit_size_doc =~ "This bit field is encoded in `8` bits."

      assert {["decode(value)"], _decode_doc} = docs_by_function[{:decode, 1}]
      assert {["encode(struct)"], _encode_doc} = docs_by_function[{:encode, 1}]
    end
  end

  describe "field/3" do
    test "generates fields with defaults, offsets, and enum sizes" do
      module = unique_module_name()

      [{compiled_module, _binary}] =
        Code.compile_string("""
        defmodule #{module} do
          @moduledoc "Dynamic bit field"
          use ArtNet.Packet.BitField

          defbitfield bit_size: 4 do
            field(:enabled, :boolean, default: false, offset: 1)
            field(:state, {:enum_table, ArtNet.Packet.EnumTable.FailsafeState})
          end
        end
        """)

      assert apply(compiled_module, :bit_field_schema, []) == [
               enabled: {:boolean, {1, 1}},
               state: {{:enum_table, ArtNet.Packet.EnumTable.FailsafeState}, {2, 2}}
             ]

      assert apply(compiled_module, :bit_size, []) == 4
    end

    test "raises for an invalid field name" do
      module = unique_module_name()

      assert_raise ArgumentError, "a field name must be an atom, got: \"invalid\"", fn ->
        Code.compile_string("""
        defmodule #{module} do
          use ArtNet.Packet.BitField

          defbitfield bit_size: 1 do
            field("invalid", :boolean)
          end
        end
        """)
      end
    end

    test "raises for a duplicate field" do
      module = unique_module_name()

      assert_raise ArgumentError, "the field :enabled is already set", fn ->
        Code.compile_string("""
        defmodule #{module} do
          use ArtNet.Packet.BitField

          defbitfield bit_size: 2 do
            field(:enabled, :boolean)
            field(:enabled, :boolean)
          end
        end
        """)
      end
    end

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

  describe "decode/2 and encode/2" do
    test "returns an error when an enum code cannot be decoded" do
      assert BitField.decode(1, LimitedBitField) == :error
    end

    test "returns an error when a field value cannot be encoded" do
      assert BitField.encode(%LimitedBitField{state: :invalid}, LimitedBitField) == :error
    end
  end

  test "documentation helpers return standalone documentation" do
    assert BitField.__moduledoc_with_layout__(false, 1, [], [], [], []) == false
    assert BitField.__bit_field_schema_doc__() =~ "schema in declaration order"
    assert BitField.__bit_size_doc__(4) =~ "encoded in `4` bits"

    assert BitField.__moduledoc_with_layout__(
             {1, "Flags"},
             1,
             [enabled: {:boolean, {0, 1}}],
             [enabled: false],
             [],
             enabled: "Enabled"
           ) =~ "Flags\n\n## Bit size"
  end

  defp unique_module_name do
    "ArtNet.Packet.BitFieldTest.Invalid#{System.unique_integer([:positive])}"
  end
end
