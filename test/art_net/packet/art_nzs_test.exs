defmodule ArtNet.Packet.ArtNzsTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtNzs

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtNzs packets" do
      packet = %ArtNzs{
        sequence: 1,
        start_code: 0x91,
        sub_universe: 2,
        net: 3,
        length: 4,
        data: [10, 20, 30, 40]
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x51, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "rejects zero and RDM start codes" do
      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} =
               ArtNet.encode(%ArtNzs{
                 sequence: 1,
                 start_code: 0,
                 sub_universe: 0,
                 net: 0,
                 length: 2,
                 data: [1, 2]
               })

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} =
               ArtNet.encode(%ArtNzs{
                 sequence: 1,
                 start_code: 0xCC,
                 sub_universe: 0,
                 net: 0,
                 length: 2,
                 data: [1, 2]
               })
    end

    test "accepts odd data length" do
      packet = %ArtNzs{
        sequence: 1,
        start_code: 0x91,
        sub_universe: 0,
        net: 0,
        length: 1,
        data: [1]
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end

  describe "validate/1" do
    test "accepts the current Art-Net length range including odd lengths" do
      packet = %ArtNzs{
        sequence: 1,
        start_code: 0x91,
        sub_universe: 0,
        net: 0,
        length: 1,
        data: [1]
      }

      assert ArtNzs.validate(packet) == :ok
      assert ArtNzs.validate(%{packet | length: 3, data: [1, 2, 3]}) == :ok
      assert ArtNzs.validate(%{packet | length: 512, data: List.duplicate(1, 512)}) == :ok
    end

    test "rejects length values outside the current Art-Net range" do
      packet = %ArtNzs{
        sequence: 1,
        start_code: 0x91,
        sub_universe: 0,
        net: 0,
        length: 1,
        data: [1]
      }

      assert ArtNzs.validate(%{packet | length: 0, data: []}) ==
               {:error, "Data length must be at least 1"}

      assert ArtNzs.validate(%{packet | length: 513, data: List.duplicate(1, 513)}) ==
               {:error, "Data length must be 512 or less"}

      assert ArtNzs.validate(%{packet | length: 2, data: [1]}) ==
               {:error, "Data length does not match the length field"}
    end
  end
end
