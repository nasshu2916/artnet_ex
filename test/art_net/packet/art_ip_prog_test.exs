defmodule ArtNet.Packet.ArtIpProgTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.BitField
  alias ArtNet.Packet.ArtIpProg

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtIpProg packets" do
      packet = %ArtIpProg{
        filler1: 0,
        filler2: 0,
        command: %BitField.IpProgCommand{enable_programming: true, program_ip: true},
        filler4: 0,
        program_ip: <<2, 0, 0, 10>>,
        program_subnet_mask: <<255, 0, 0, 0>>,
        program_port: 0x1936,
        program_default_gateway: <<2, 0, 0, 1>>,
        spare: <<0::size(32)>>
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0xF8, _::binary>> = binary
      assert <<_header::binary-size(14), 0x84, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
