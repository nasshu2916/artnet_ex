defmodule ArtNet.Packet.ArtTodRequestTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtTodRequest

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtTodRequest packets" do
      packet = %ArtTodRequest{
        filler1: 0,
        filler2: 0,
        spare: <<0::size(56)>>,
        net: 1,
        command: :tod_full,
        address_count: 2,
        address: [1, 2] ++ List.duplicate(0, 30)
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x80, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
