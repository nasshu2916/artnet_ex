defmodule ArtNet.Packet.ArtDirectoryTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtDirectory

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtDirectory packets" do
      packet = %ArtDirectory{
        filler: <<0, 0>>,
        command: 1,
        file: 2
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x9A, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
