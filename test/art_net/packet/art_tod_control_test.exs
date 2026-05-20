defmodule ArtNet.Packet.ArtTodControlTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtTodControl

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtTodControl packets" do
      packet = %ArtTodControl{
        filler1: 0,
        filler2: 0,
        spare: <<0::size(56)>>,
        net: 0,
        command: :atc_flush,
        address: 1
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x82, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
