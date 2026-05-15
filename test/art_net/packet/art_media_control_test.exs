defmodule ArtNet.Packet.ArtMediaControlTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtMediaControl

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtMediaControl packets" do
      packet = %ArtMediaControl{
        filler1: 0,
        filler2: 0,
        filler3: 0,
        filler4: 0,
        stream: 1,
        control_command: 2,
        command_data1: 3,
        command_data2: 4,
        command_data3: 5,
        command_data4: 6,
        command_data5: 7,
        command_data6: 8
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x92, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
