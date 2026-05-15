defmodule ArtNet.Packet.ArtInputTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtInput

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtInput packets" do
      packet = %ArtInput{filler1: 0, bind_index: 1, num_ports: 4, input: [1, 0, 1, 0]}

      assert {:ok, binary} = ArtNet.encode(packet)
      assert <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x70, _::binary>> = binary
      assert {:ok, ^packet} = ArtNet.decode(binary)
    end
  end
end
