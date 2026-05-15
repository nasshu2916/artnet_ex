defmodule ArtNet.Packet.ArtMediaTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtMedia

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtMedia packets" do
      packet = %ArtMedia{
        filler1: 0,
        filler2: 0,
        filler3: 0,
        filler4: 0,
        stream: 1,
        command: 0,
        command_data1: 0x11,
        command_data2: 0x22,
        command_data3: 0x33,
        packs: [0xFF, 0, 1, 0x44, 0x55, 0x66]
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x90, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "rejects invalid pack length" do
      packet = %ArtMedia{
        stream: 1,
        command: 0,
        command_data1: 0,
        command_data2: 0,
        command_data3: 0,
        packs: [1]
      }

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} = ArtNet.encode(packet)
    end
  end
end
