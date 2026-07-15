defmodule ArtNet.EncoderTest do
  use ExUnit.Case, async: true

  doctest ArtNet.Encoder

  alias ArtNet.Packet.BitField.TalkToMe
  alias ArtNet.Packet.EnumTable.Priority

  defmodule FailingBitField do
    defstruct []

    def bit_size, do: 1
    def encode(%__MODULE__{}), do: :error
  end

  test "encode/3 dispatches every schema format" do
    flags = %TalkToMe{
      reply_on_change: true,
      diagnostics: false,
      diag_unicast: false,
      vlc: true,
      targeted_mode: false
    }

    assert ArtNet.Encoder.encode([1, 2], [{:integer, 8}], []) == {:ok, <<1, 2>>}
    assert ArtNet.Encoder.encode(0x0201, {:integer, 16, :little_endian}, []) == {:ok, <<1, 2>>}
    assert ArtNet.Encoder.encode(<<1>>, {:binary, 2}, []) == {:ok, <<1, 0>>}
    assert ArtNet.Encoder.encode("A", {:string, 2}, []) == {:ok, <<?A, 0>>}
    assert ArtNet.Encoder.encode(:dp_med, {:enum_table, Priority}, []) == {:ok, <<0x40>>}
    assert ArtNet.Encoder.encode(flags, {:bit_field, TalkToMe}, []) == {:ok, <<0x12>>}
  end

  test "encode_list_with/2 uses the supplied encoder" do
    assert ArtNet.Encoder.encode_list_with([1, 2], &ArtNet.Encoder.integer(&1, 8)) ==
             {:ok, <<1, 2>>}
  end

  test "encode_list_with/3 rejects an improper list tail" do
    assert ArtNet.Encoder.encode_list_with([1 | 2], &ArtNet.Encoder.integer(&1, 8), []) ==
             {:error, :not_list}
  end

  test "bit_field/1 rejects invalid field values" do
    assert ArtNet.Encoder.bit_field(%FailingBitField{}) == :error
  end
end
