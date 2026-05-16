defmodule ArtNet.Packet.ArtRdmTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtRdm

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtRdm packets" do
      packet = %ArtRdm{
        rdm_version: 1,
        filler2: 0,
        spare: <<0::size(40)>>,
        fifo_available: 0,
        fifo_max: 0,
        net: 0,
        command: :ar_process,
        address: 1,
        rdm_packet: [1, 2, 3, 4]
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x83, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
