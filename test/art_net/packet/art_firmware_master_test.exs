defmodule ArtNet.Packet.ArtFirmwareMasterTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtFirmwareMaster

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtFirmwareMaster packets" do
      packet = %ArtFirmwareMaster{
        filler1: 0,
        filler2: 0,
        type: :firm_first,
        block_id: 0,
        firmware_length: 0x0000_8212,
        spare: <<0::size(160)>>,
        data: [0x1234 | List.duplicate(0, 511)]
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0xF2, _::binary>> = binary
      assert <<_header::binary-size(12), 0, 0, 0, 0, 0, 0, 0x82, 0x12, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
