defmodule ArtNet.Packet.ArtAddressTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtAddress

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtAddress packets" do
      packet = %ArtAddress{
        net_switch: 0x80,
        bind_index: 1,
        port_name: "Port A",
        long_name: "Main stage node",
        sw_in: [0x80, 0, 0, 0],
        sw_out: [0x80, 0, 0, 0],
        sub_switch: 0x80,
        acn_priority: 100,
        command: :ac_none
      }

      assert {:ok, binary} = ArtNet.encode(packet)

      assert <<"Art-Net", 0, 0x00, 0x60, 0x00, 0x0E, body::binary>> = binary

      assert body ==
               <<0x80, 0x01, "Port A", 0::size(12 * 8), "Main stage node", 0::size(49 * 8), 0x80,
                 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x64, 0x00>>

      assert {:ok, ^packet} = ArtNet.decode(binary)
    end

    test "uses no-change ACN priority by default" do
      packet = %ArtAddress{
        net_switch: 0,
        bind_index: 1,
        port_name: "",
        long_name: "",
        sw_in: [0, 0, 0, 0],
        sw_out: [0, 0, 0, 0]
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<"Art-Net", 0, 0x00, 0x60, 0x00, 0x0E, body::binary>> = binary
      assert <<_::binary-size(93), 0x00, 0x00>> = body
    end

    test "rejects malformed switch list lengths" do
      packet = %ArtAddress{
        net_switch: 0,
        bind_index: 1,
        port_name: "",
        long_name: "",
        sw_in: [0, 0, 0],
        sw_out: [0, 0, 0, 0]
      }

      assert ArtNet.encode(packet) ==
               {:error,
                %ArtNet.EncodeError{reason: {:invalid_data, "sw_in must contain 4 values, got 3"}}}
    end

    test "rejects non-list switch fields" do
      packet = %ArtAddress{
        net_switch: 0,
        bind_index: 1,
        port_name: "",
        long_name: "",
        sw_in: :invalid,
        sw_out: [0, 0, 0, 0]
      }

      assert ArtNet.encode(packet) ==
               {:error, %ArtNet.EncodeError{reason: {:invalid_data, "sw_in must be a list"}}}
    end
  end
end
