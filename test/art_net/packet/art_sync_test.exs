defmodule ArtNet.Packet.ArtSyncTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtSync

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtSync packets" do
      packet = %ArtSync{aux1: 0, aux2: 0}

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x52, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
