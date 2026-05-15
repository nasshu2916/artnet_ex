defmodule ArtNet.Packet.ArtMediaPatchTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtMediaPatch

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtMediaPatch packets" do
      packet = %ArtMediaPatch{
        filler1: 0,
        filler2: 0,
        filler3: 0,
        filler4: 0,
        stream: 1,
        patch_command: 0,
        virtual_delta_x: 1920,
        virtual_delta_y: 1080,
        coordinate_count: 1,
        aperture: 1,
        diameter: 3,
        coordinates: [0, 1, 0, 10, 0, 20]
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x91, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "rejects invalid coordinate length" do
      packet = %ArtMediaPatch{
        stream: 1,
        patch_command: 0,
        virtual_delta_x: 1,
        virtual_delta_y: 1,
        coordinate_count: 1,
        aperture: 0,
        diameter: 1,
        coordinates: [1]
      }

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} = ArtNet.encode(packet)
    end
  end
end
