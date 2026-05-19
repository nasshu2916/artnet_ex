defmodule ArtNet.Packet.ArtSyncTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtSync

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtSync packets" do
      packet = %ArtSync{aux1: 0, aux2: 0}

      assert {:ok, binary} = ArtNet.encode(packet)

      assert <<"Art-Net", 0, 0x00, 0x52, 0x00, 0x0E, body::binary>> = binary
      assert body == <<0x00, 0x00>>

      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
