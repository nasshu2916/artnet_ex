defmodule ArtNet.Packet.ArtTodDataTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtTodData

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtTodData packets" do
      packet = %ArtTodData{
        rdm_version: 1,
        port: 1,
        spare: <<0::size(48)>>,
        bind_index: 1,
        net: 0,
        command_response: :tod_full,
        address: 1,
        uid_total: 2,
        block_count: 0,
        uid_count: 2,
        tod: [<<1, 2, 3, 4, 5, 6>>, <<7, 8, 9, 10, 11, 12>>]
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x81, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "rejects mismatched ToD count" do
      packet = %ArtTodData{
        rdm_version: 1,
        port: 1,
        spare: <<0::size(48)>>,
        bind_index: 1,
        net: 0,
        command_response: :tod_full,
        address: 1,
        uid_total: 1,
        block_count: 0,
        uid_count: 2,
        tod: [<<1, 2, 3, 4, 5, 6>>]
      }

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} = ArtNet.encode(packet)
    end
  end
end
