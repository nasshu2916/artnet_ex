defmodule ArtNet.Packet.ArtVideoDataTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtVideoData

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtVideoData packets" do
      packet = %ArtVideoData{
        filler1: 0,
        filler2: 0,
        position_x: 1,
        position_y: 2,
        length_x: 2,
        length_y: 1,
        data: [0x41, 0x07, 0x42, 0x07]
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x40, 0xA0, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "rejects mismatched video data length" do
      packet = %ArtVideoData{
        position_x: 0,
        position_y: 0,
        length_x: 2,
        length_y: 1,
        data: [0]
      }

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} = ArtNet.encode(packet)
    end
  end
end
