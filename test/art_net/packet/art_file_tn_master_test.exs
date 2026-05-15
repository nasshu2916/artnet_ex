defmodule ArtNet.Packet.ArtFileTnMasterTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtFileTnMaster

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtFileTnMaster packets" do
      packet = %ArtFileTnMaster{
        filler1: 0,
        filler2: 0,
        type: 0,
        block_id: 1,
        length: 4,
        name: "show.dat",
        checksum: 0x1234,
        spare: <<0, 0, 0, 0>>,
        data: <<1, 2, 3, 4>>
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0xF4, _::binary>> = binary
      assert {:ok, decoded} = ArtNet.decode(binary)
      assert decoded == %{packet | data: <<1, 2, 3, 4, 0::size(4064)>>}
    end
  end
end
