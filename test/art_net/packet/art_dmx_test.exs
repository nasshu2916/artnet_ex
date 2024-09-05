defmodule ArtNet.Packet.ArtDmxTest do
  use ExUnit.Case, async: true

  test "decode/encode" do
    packet = %ArtNet.Packet.ArtDmx{
      sequence: 1,
      physical: 0,
      sub_universe: 0,
      net: 0,
      length: 1,
      data: [255]
    }

    data =
      <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00,
        0x00, 0x00, 0x01, 0xFF>>

    assert ArtNet.Packet.ArtDmx.decode(data) == {:ok, packet}
    assert ArtNet.Packet.ArtDmx.encode(packet) == {:ok, data}
  end

  test "validate" do
    packet = %ArtNet.Packet.ArtDmx{
      sequence: 1,
      physical: 0,
      sub_universe: 0,
      net: 0,
      length: 1,
      data: [255]
    }

    assert ArtNet.Packet.ArtDmx.validate(packet) == :ok

    assert ArtNet.Packet.ArtDmx.validate(%{packet | length: 2}) ==
             {:error, "Data length does not match the length field"}
  end
end
