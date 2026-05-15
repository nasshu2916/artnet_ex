defmodule ArtNet.Packet.ArtVideoSetupTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtVideoSetup

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtVideoSetup packets" do
      packet = %ArtVideoSetup{
        filler: <<0, 0, 0, 0>>,
        control: 1,
        font_height: 8,
        first_font: 0,
        last_font: 2,
        windows_font_name: "Terminal",
        font_data: List.duplicate(0xAA, 16)
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x10, 0xA0, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "rejects mismatched font data length" do
      packet = %ArtVideoSetup{
        control: 1,
        font_height: 8,
        first_font: 0,
        last_font: 2,
        windows_font_name: "Terminal",
        font_data: [0]
      }

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} = ArtNet.encode(packet)
    end
  end
end
