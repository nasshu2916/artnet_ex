defmodule ArtNet.Packet.ArtFirmwareReplyTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtFirmwareReply

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtFirmwareReply packets" do
      packet = %ArtFirmwareReply{
        filler1: 0,
        filler2: 0,
        type: :firm_block_good,
        spare: <<0::size(168)>>
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0xF3, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
