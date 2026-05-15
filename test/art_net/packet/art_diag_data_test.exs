defmodule ArtNet.Packet.ArtDiagDataTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtDiagData

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtDiagData packets" do
      packet = %ArtDiagData{
        filler1: 0,
        priority: :dp_low,
        logical_port: 0,
        filler3: 0,
        length: 6,
        data: ~c"test\0\0"
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x23, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "rejects mismatched data length" do
      packet = %ArtDiagData{
        filler1: 0,
        priority: :dp_low,
        logical_port: 0,
        filler3: 0,
        length: 1,
        data: [1, 2]
      }

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} = ArtNet.encode(packet)
    end
  end
end
