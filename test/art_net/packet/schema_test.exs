defmodule ArtNet.Packet.SchemaTest do
  use ExUnit.Case

  doctest ArtNet.Packet.Schema

  alias ArtNet.Packet.Schema

  defmodule ValidationTarget do
    defstruct [:value]

    def validate_encode(%__MODULE__{value: :ok}), do: :ok
    def validate_encode(%__MODULE__{value: :text_error}), do: {:error, "invalid value"}
    def validate_encode(%__MODULE__{}), do: {:error, :invalid_value}
  end

  describe "__new__/2 and __new__!/2" do
    test "build validated structs from maps and keyword lists" do
      assert Schema.__new__(ValidationTarget, %{value: :ok}) ==
               {:ok, %ValidationTarget{value: :ok}}

      assert Schema.__new__!(ValidationTarget, value: :ok) == %ValidationTarget{value: :ok}
    end

    test "return an encode error for invalid attributes" do
      assert Schema.__new__(ValidationTarget, :invalid) ==
               {:error,
                %ArtNet.EncodeError{
                  reason: {:invalid_data, "attributes must be a map or keyword list"}
                }}

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, unknown_key_error}}} =
               Schema.__new__(ValidationTarget, unknown: true)

      assert unknown_key_error =~ "key :unknown not found"
    end

    test "return an encode error for validation failures" do
      assert Schema.__new__(ValidationTarget, value: :text_error) ==
               {:error, %ArtNet.EncodeError{reason: {:invalid_data, "invalid value"}}}

      assert Schema.__new__(ValidationTarget, value: :other) ==
               {:error, %ArtNet.EncodeError{reason: {:invalid_data, ":invalid_value"}}}

      assert_raise ArtNet.EncodeError, "invalid data: invalid value", fn ->
        Schema.__new__!(ValidationTarget, value: :text_error)
      end
    end
  end

  describe "generated docs" do
    test "documents packet layout in the module" do
      assert {:docs_v1, _, :elixir, "text/markdown", %{"en" => moduledoc}, _, docs} =
               Code.fetch_docs(ArtNet.Packet.ArtDmx)

      assert moduledoc =~ "Transmits zero-start-code DMX512 data for a single universe."
      assert moduledoc =~ "## Packet layout"
      assert moduledoc =~ "| Part | Field | Description | Default | Size | Format |"
      assert moduledoc =~ "| Header | `id` |  | fixed | 8 bytes | `\"Art-Net\\\\0\"` |"
      assert moduledoc =~ "| Header | `op_code` |  | `0x5000` | 2 bytes | little-endian OpCode |"
      assert moduledoc =~ "| Header | `prot_ver` |  | `14` | 2 bytes | protocol version |"

      assert moduledoc =~
               "| Payload | `length` | Number of DMX512 slots included in the data field. | required | 2 bytes | unsigned integer (16 bits) |"

      assert moduledoc =~
               "| Payload | `data` | DMX512 level data, one byte per slot. | required | variable (1 byte each) | list of unsigned integer (8 bits) |"

      docs_by_function = docs_by_function(docs)

      assert {["schema()"], schema_doc} = docs_by_function[{:schema, 0}]
      assert schema_doc =~ "Returns the packet payload schema in declaration order."
      refute schema_doc =~ "## Packet layout"
      refute schema_doc =~ "| Part | Field | Description | Default | Size | Format |"

      assert {["op_code()"], op_code_doc} = docs_by_function[{:op_code, 0}]
      assert op_code_doc =~ "The OpCode is `0x5000`."

      assert {["decode(data)"], _decode_doc} = docs_by_function[{:decode, 1}]
      assert {["encode(packet)"], _encode_doc} = docs_by_function[{:encode, 1}]
    end

    test "omits protocol version header when the packet does not use it" do
      assert {:docs_v1, _, :elixir, "text/markdown", %{"en" => moduledoc}, _, _docs} =
               Code.fetch_docs(ArtNet.Packet.ArtPollReply)

      refute moduledoc =~ "`prot_ver`"
      assert moduledoc =~ "| Header | `op_code` |  | `0x2100` | 2 bytes | little-endian OpCode |"
    end
  end

  test "generates OpCode metadata used by the registry" do
    assert ArtNet.Packet.ArtDmx.__op_code__() == {:op_dmx, 0x5000}
    assert ArtNet.Packet.ArtDmx.op_code() == 0x5000
    assert ArtNet.OpCode.op_code(ArtNet.Packet.ArtDmx) == 0x5000
    assert ArtNet.OpCode.op_code(:op_dmx) == 0x5000
    assert ArtNet.OpCode.op_code_type(0x5000) == :op_dmx
    assert ArtNet.OpCode.packet_module_from_value(0x5000) == ArtNet.Packet.ArtDmx
  end

  describe "field/3" do
    test "raises for an invalid field name" do
      assert_raise ArgumentError, "a field name must be an atom, got: \"invalid\"", fn ->
        compile_packet("field(\"invalid\", {:integer, 8})")
      end
    end

    test "raises for a duplicate field" do
      assert_raise ArgumentError, "the field :value is already set", fn ->
        compile_packet("field(:value, {:integer, 8})\nfield(:value, {:integer, 8})")
      end
    end

    test "raises when a field description is not a string" do
      assert_raise ArgumentError,
                   "the description option for field :value must be a string, got: :bad",
                   fn ->
                     compile_packet("field(:value, {:integer, 8}, description: :bad)")
                   end
    end
  end

  defp docs_by_function(docs) do
    Map.new(docs, fn
      {{:function, name, arity}, _, signatures, %{"en" => doc}, _} ->
        {{name, arity}, {signatures, doc}}

      {{:function, name, arity}, _, signatures, doc, _} ->
        {{name, arity}, {signatures, doc}}

      {kind, _, signatures, doc, _} ->
        {kind, {signatures, doc}}
    end)
  end

  defp compile_packet(fields) do
    Code.compile_string("""
    defmodule #{unique_module_name()} do
      @moduledoc false
      use ArtNet.Packet.Schema

      defpacket op_code: 0xFFFF do
        #{fields}
      end
    end
    """)
  end

  defp unique_module_name do
    "ArtNet.Packet.ArtSchemaTestDynamic#{System.unique_integer([:positive])}"
  end
end
