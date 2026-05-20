defmodule ArtNet.Packet.SchemaTest do
  use ExUnit.Case

  doctest ArtNet.Packet.Schema

  describe "generated docs" do
    test "documents packet layout in the module and schema function" do
      assert {:docs_v1, _, :elixir, "text/markdown", %{"en" => moduledoc}, _, docs} =
               Code.fetch_docs(ArtNet.Packet.ArtDmx)

      assert moduledoc =~ "## Packet layout"
      assert moduledoc =~ "| Part | Field | Size | Format | Default |"
      assert moduledoc =~ "| Header | `id` | 8 bytes | `\"Art-Net\\\\0\"` | fixed |"
      assert moduledoc =~ "| Header | `op_code` | 2 bytes | little-endian OpCode | `0x5000` |"
      assert moduledoc =~ "| Header | `prot_ver` | 2 bytes | protocol version | `14` |"

      assert moduledoc =~
               "| Payload | `length` | 2 bytes | unsigned integer (16 bits) | required |"

      assert moduledoc =~
               "| Payload | `data` | variable (1 byte each) | list of unsigned integer (8 bits) | required |"

      docs_by_function = docs_by_function(docs)

      assert {["schema()"], schema_doc} = docs_by_function[{:schema, 0}]
      assert schema_doc =~ "Returns the packet payload schema in declaration order."
      assert schema_doc =~ "| Payload | `sequence` | 1 byte | unsigned integer (8 bits) | `0` |"

      assert {["op_code()"], op_code_doc} = docs_by_function[{:op_code, 0}]
      assert op_code_doc =~ "The OpCode is `0x5000`."

      assert {["decode(data)"], _decode_doc} = docs_by_function[{:decode, 1}]
      assert {["encode(packet)"], _encode_doc} = docs_by_function[{:encode, 1}]
    end

    test "omits protocol version header when the packet does not use it" do
      assert {:docs_v1, _, :elixir, "text/markdown", %{"en" => moduledoc}, _, _docs} =
               Code.fetch_docs(ArtNet.Packet.ArtPollReply)

      refute moduledoc =~ "`prot_ver`"
      assert moduledoc =~ "| Header | `op_code` | 2 bytes | little-endian OpCode | `0x2100` |"
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
end
