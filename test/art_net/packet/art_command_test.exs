defmodule ArtNet.Packet.ArtCommandTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtCommand

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtCommand packets" do
      packet = %ArtCommand{
        esta_manufacturer: 0x414C,
        length: 10,
        data: ~c"Command&\0\0"
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x24, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "rejects mismatched data length" do
      packet = %ArtCommand{esta_manufacturer: 0x414C, length: 1, data: [1, 2]}

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} = ArtNet.encode(packet)
    end
  end
end
