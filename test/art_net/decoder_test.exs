defmodule ArtNet.DecoderTest do
  use ExUnit.Case, async: true

  doctest ArtNet.Decoder

  alias ArtNet.Packet.BitField.TalkToMe
  alias ArtNet.Packet.EnumTable.Priority

  test "decode/3 dispatches every schema format" do
    assert ArtNet.Decoder.decode(<<1, 2, 3>>, [{:integer, 8}], length: 2) ==
             {:ok, {[1, 2], <<3>>}}

    assert ArtNet.Decoder.decode(<<1, 2>>, {:integer, 16, :little_endian}, []) ==
             {:ok, {0x0201, <<>>}}

    assert ArtNet.Decoder.decode(<<1, 2>>, {:binary, 1}, []) == {:ok, {<<1>>, <<2>>}}
    assert ArtNet.Decoder.decode(<<?A, 0>>, {:string, 2}, []) == {:ok, {"A", <<>>}}
    assert ArtNet.Decoder.decode(<<0x40>>, {:enum_table, Priority}, []) == {:ok, {:dp_med, <<>>}}

    assert {:ok, {%TalkToMe{reply_on_change: true, vlc: true}, <<>>}} =
             ArtNet.Decoder.decode(<<0x12>>, {:bit_field, TalkToMe}, [])
  end

  test "string/2 rejects data shorter than the requested size" do
    assert ArtNet.Decoder.string("A", 2) == :error
  end
end
