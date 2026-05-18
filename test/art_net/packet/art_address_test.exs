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
  end
end
