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

    body = <<0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>
    data = <<"Art-Net", 0, 0x00, 0x50, 0x00, 0x0E, body::binary>>

    assert ArtNet.Packet.ArtDmx.decode(data) == {:ok, packet}
    assert {:ok, encoded} = ArtNet.Packet.ArtDmx.encode(packet)
    assert <<"Art-Net", 0, 0x00, 0x50, 0x00, 0x0E, encoded_body::binary>> = encoded
    assert encoded_body == body
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

    assert ArtNet.Packet.ArtDmx.validate(%{packet | length: 0, data: []}) ==
             {:error, "Data length must be at least 1"}
  end
end
