defmodule ArtNet.Packet.ArtTimeCodeTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtTimeCode

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtTimeCode packets" do
      packet = %ArtTimeCode{
        filler1: 0,
        stream_id: 0,
        frames: 12,
        seconds: 34,
        minutes: 56,
        hours: 1,
        type: :smpte
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x97, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
