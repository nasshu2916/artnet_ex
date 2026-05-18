defmodule ArtNet.Packet.Schema.CodeGeneratorTest.Generator do
  alias ArtNet.Packet.Schema.CodeGenerator

  defmacro generate(schema, opts) do
    {schema, _} = Code.eval_quoted(schema, [], __CALLER__)
    {opts, _} = Code.eval_quoted(opts, [], __CALLER__)

    CodeGenerator.generate(schema, opts)
  end
end

defmodule ArtNet.Packet.Schema.CodeGeneratorTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.Schema.CodeGeneratorTest.Generator

  defmodule GeneratedPacket do
    @behaviour ArtNet.Packet.Schema

    require Generator

    defstruct [:be, :le, :data, :name, :items]

    @type t :: %__MODULE__{
            be: integer,
            le: integer,
            data: binary,
            name: String.t(),
            items: [integer]
          }

    @impl ArtNet.Packet.Schema
    def validate(_), do: :ok

    Generator.generate(
      [
        be: {{:integer, 8}, []},
        le: {{:integer, 16, :little_endian}, []},
        data: {{:binary, 2}, []},
        name: {{:string, 4}, []},
        items: {[{:integer, 8}], [length: 2]}
      ],
      pre_decode_defined?: false
    )
  end

  defmodule PreDecodedPacket do
    @behaviour ArtNet.Packet.Schema

    require Generator

    defstruct [:value]

    @type t :: %__MODULE__{value: integer}

    @impl ArtNet.Packet.Schema
    def validate(_), do: :ok

    @impl ArtNet.Packet.Schema
    def pre_decode(<<value>>), do: <<0, value>>

    Generator.generate([value: {{:integer, 16}, []}], pre_decode_defined?: true)
  end

  test "generates default pre_decode when the packet does not define one" do
    assert GeneratedPacket.pre_decode(<<1, 2>>) == <<1, 2>>
  end

  test "generates decode body from schema fields" do
    binary = <<1, 3, 2, 0xAA, 0xBB, ?A, 0, 0, 0, 4, 5>>

    assert GeneratedPacket.__decode_body__(binary) ==
             {:ok,
              %GeneratedPacket{
                be: 1,
                le: 0x0203,
                data: <<0xAA, 0xBB>>,
                name: "A",
                items: [4, 5]
              }}
  end

  test "generated decode body reports the failed field" do
    binary = <<1, 3, 2, 0xAA, 0xBB, ?A, 0, 0, 0, 4>>

    assert GeneratedPacket.__decode_body__(binary) ==
             {:error, %ArtNet.DecodeError{reason: {:decode_error, :items}}}
  end

  test "generated decode body reports excess bytes" do
    binary = <<1, 3, 2, 0xAA, 0xBB, ?A, 0, 0, 0, 4, 5, 0xFF>>

    assert GeneratedPacket.__decode_body__(binary) ==
             {:error, %ArtNet.DecodeError{reason: {:excess_bytes, <<0xFF>>}}}
  end

  test "generates encode body from schema fields" do
    packet = %GeneratedPacket{
      be: 1,
      le: 0x0203,
      data: <<0xAA, 0xBB>>,
      name: "A",
      items: [4, 5]
    }

    assert GeneratedPacket.__encode_body__(packet) ==
             {:ok, <<1, 3, 2, 0xAA, 0xBB, ?A, 0, 0, 0, 4, 5>>}
  end

  test "generated encode body reports the failed field" do
    packet = %GeneratedPacket{
      be: 0x100,
      le: 0x0203,
      data: <<0xAA, 0xBB>>,
      name: "A",
      items: [4, 5]
    }

    assert GeneratedPacket.__encode_body__(packet) ==
             {:error,
              %ArtNet.EncodeError{
                reason: {:encode_error, %{key: :be, type: {:integer, 8}, value: 0x100}}
              }}
  end

  test "uses a packet-defined pre_decode when one exists" do
    assert PreDecodedPacket.pre_decode(<<5>>) == <<0, 5>>
    assert PreDecodedPacket.__decode_body__(<<5>>) == {:ok, %PreDecodedPacket{value: 5}}
  end
end
