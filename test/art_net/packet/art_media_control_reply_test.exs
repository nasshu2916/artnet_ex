defmodule ArtNet.Packet.ArtMediaControlReplyTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtMediaControlReply

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtMediaControlReply packets" do
      packet = %ArtMediaControlReply{
        filler1: 0,
        filler2: 0,
        filler3: 0,
        filler4: 0,
        stream: 1,
        reply_command: 6,
        max_clips: 12,
        time_code_day: 0,
        time_code_hour: 1,
        time_code_minute: 2,
        time_code_second: 3,
        time_code_frames: 4,
        time_code_mode: 3,
        status1: 0x80,
        status2: 0,
        status3: 0,
        status4: 0,
        data: [6, 1, 0, 1]
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x93, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "rejects empty data" do
      packet = %ArtMediaControlReply{
        stream: 1,
        reply_command: 0,
        max_clips: 0,
        time_code_day: 0,
        time_code_hour: 0,
        time_code_minute: 0,
        time_code_second: 0,
        time_code_frames: 0,
        time_code_mode: 0,
        status1: 0,
        data: []
      }

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} = ArtNet.encode(packet)
    end
  end
end
