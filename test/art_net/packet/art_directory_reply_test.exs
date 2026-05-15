defmodule ArtNet.Packet.ArtDirectoryReplyTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtDirectoryReply

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtDirectoryReply packets" do
      packet = %ArtDirectoryReply{
        filler: <<0, 0>>,
        flags: 1,
        file: 2,
        name: "config.bin",
        description: "configuration",
        length: 1234,
        data: <<1, 2, 3, 4>>
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x9B, _::binary>> = binary
      assert {:ok, decoded} = ArtNet.decode(binary)
      assert decoded == %{packet | data: <<1, 2, 3, 4, 0::size(480)>>}
    end
  end
end
