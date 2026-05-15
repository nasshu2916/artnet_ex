defmodule ArtNet.Packet.ArtDataRequestTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtDataRequest

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtDataRequest packets" do
      packet = %ArtDataRequest{
        esta_manufacturer: 0x414C,
        oem: 0x1234,
        request: 0x0004,
        spare: <<0::size(176)>>
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x27, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
