defmodule ArtNetTest do
  use ExUnit.Case, async: true
  doctest ArtNet

  test "decode!/1" do
    assert_raise ArtNet.DecodeError, "invalid data: Invalid identifier", fn ->
      ArtNet.decode!(<<>>)
    end

    assert_raise ArtNet.DecodeError, "invalid data: Invalid identifier", fn ->
      ArtNet.decode!(
        <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x01, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00,
          0x00, 0x00, 0x00, 0x01, 0xFF>>
      )
    end

    assert_raise ArtNet.DecodeError, "not supported op code: 0x5100", fn ->
      ArtNet.decode!(
        <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x51, 0x00, 0x0E, 0x01, 0x00,
          0x00, 0x00, 0x00, 0x01, 0xFF>>
      )
    end

    assert_raise ArtNet.DecodeError,
                 "invalid data: Data length does not match the length field",
                 fn ->
                   ArtNet.decode!(
                     <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E,
                       0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF, 0xFF>>
                   )
                 end

    assert_raise ArtNet.DecodeError, "found excess bytes: <<0x12>>", fn ->
      ArtNet.decode!(
        <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x20, 0x00, 0x0E, 0x00, 0x00,
          0x12>>
      )
    end
  end

  test "encode!/1" do
    art_dmx = %ArtNet.Packet.ArtDmx{
      sequence: 1,
      physical: 0,
      sub_universe: 0,
      net: 0,
      length: 1,
      data: [255]
    }

    assert_raise ArtNet.EncodeError,
                 "invalid data: Data length does not match the length field",
                 fn ->
                   ArtNet.encode!(%{art_dmx | data: [255, 255]})
                 end

    assert_raise ArtNet.EncodeError,
                 "encoding error: %{type: [integer: 8], value: [65535], key: :data}",
                 fn ->
                   ArtNet.encode!(%{art_dmx | data: [0xFFFF]})
                 end
  end
end
