defmodule ArtNet.Packet.ArtFileFnMasterTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtFileFnMaster

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtFileFnMaster packets" do
      packet = %ArtFileFnMaster{}

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0xF5, 0, 14>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
