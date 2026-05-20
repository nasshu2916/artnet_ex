defmodule ArtNet.Packet.ArtTriggerTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtTrigger

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtTrigger packets" do
      packet = %ArtTrigger{
        filler1: 0,
        filler2: 0,
        oem: 0xFFFF,
        key: 1,
        sub_key: 2,
        data: List.duplicate(0, 512)
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x99, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
