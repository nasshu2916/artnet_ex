defmodule ArtNet.Packet.ArtVideoPaletteTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtVideoPalette

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtVideoPalette packets" do
      packet = %ArtVideoPalette{
        filler1: 0,
        filler2: 0,
        colour_red: List.duplicate(0x3F, 17),
        colour_green: List.duplicate(0x20, 17),
        colour_blue: List.duplicate(0x10, 17)
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x20, 0xA0, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
