defmodule ArtNet.Packet.SchemaTest do
  use ExUnit.Case

  doctest ArtNet.Packet.Schema

  describe "generated docs" do
    test "documents packet layout in the module and schema function" do
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

      assert schema_doc =~
               "| Payload | `sequence` | Packet sequence number, or 0 to disable sequence checking. | `0` | 1 byte | unsigned integer (8 bits) |"

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
