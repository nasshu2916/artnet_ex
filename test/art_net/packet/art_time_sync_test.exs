defmodule ArtNet.Packet.ArtTimeSyncTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtTimeSync

  describe "encode/1 and decode/1" do
    test "encodes and decodes header-only ArtTimeSync packets" do
      packet = %ArtTimeSync{}

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x98, 0, 14>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "encodes and decodes ArtTimeSync packets with opaque payload bytes" do
      packet = %ArtTimeSync{payload: <<0x01, 0x02, 0x03, 0x04>>}

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<"Art-Net", 0, 0x00, 0x98, 0x00, 0x0E, payload::binary>> = binary
      assert payload == <<0x01, 0x02, 0x03, 0x04>>
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
