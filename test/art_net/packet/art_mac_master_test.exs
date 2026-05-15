defmodule ArtNet.Packet.ArtMacMasterTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtMacMaster

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtMacMaster packets" do
      packet = %ArtMacMaster{}

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0xF0, 0, 14>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
