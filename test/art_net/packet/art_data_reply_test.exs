defmodule ArtNet.Packet.ArtDataReplyTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtDataReply

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtDataReply packets" do
      packet = %ArtDataReply{
        esta_manufacturer: 0x414C,
        oem: 0x1234,
        request: 0x0004,
        payload_length: 12,
        payload: ~c"https://a/\0\0"
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x28, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "rejects mismatched payload length" do
      packet = %ArtDataReply{
        esta_manufacturer: 0x414C,
        oem: 0x1234,
        request: 0x0004,
        payload_length: 1,
        payload: [1, 2]
      }

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} = ArtNet.encode(packet)
    end
  end
end
