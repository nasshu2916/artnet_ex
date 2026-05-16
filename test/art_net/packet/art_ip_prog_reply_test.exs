defmodule ArtNet.Packet.ArtIpProgReplyTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.BitField
  alias ArtNet.Packet.ArtIpProgReply

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtIpProgReply packets" do
      packet = %ArtIpProgReply{
        filler1: 0,
        filler2: 0,
        filler3: 0,
        filler4: 0,
        program_ip: <<2, 0, 0, 10>>,
        program_subnet_mask: <<255, 0, 0, 0>>,
        program_port: 0x1936,
        status: %BitField.IpProgStatus{dhcp_enabled: true},
        spare2: 0,
        program_default_gateway: <<2, 0, 0, 1>>,
        spare: <<0::size(16)>>
      }

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0xF9, _::binary>> = binary
      assert <<_header::binary-size(26), 0x40, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
