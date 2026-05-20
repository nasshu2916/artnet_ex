defmodule ArtNet.Packet.ArtVlcTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtNzs
  alias ArtNet.Packet.ArtVlc

  describe "decode/1" do
    test "decodes an ArtNzs VLC payload into structured fields" do
      packet = packet(payload: [1, 2, 3])

      assert ArtVlc.decode(packet) ==
               {:ok,
                %ArtVlc{
                  sequence: 1,
                  sub_universe: 2,
                  net: 3,
                  man_id: 0x414C,
                  sub_code: 0x45,
                  flags: %ArtVlc.Flags{
                    ieee?: true,
                    reply?: false,
                    beacon?: true,
                    raw: 0b1010_0000
                  },
                  transaction: 0x1234,
                  slot_address: 0x0002,
                  payload_count: 3,
                  payload_checksum: 6,
                  spare: 0,
                  vlc_depth: 75,
                  vlc_frequency: 1200,
                  vlc_modulation: 2,
                  payload_language: 1,
                  beacon_repeat: 30,
                  payload: [1, 2, 3]
                }}
    end

    test "decodes from an Art-Net binary" do
      assert {:ok, binary} = packet(payload: [4, 5]) |> ArtNet.encode()

      assert {:ok, %ArtVlc{payload: [4, 5], payload_checksum: 9}} = ArtVlc.decode(binary)
    end

    test "rejects ArtNzs packets with a non-VLC start code" do
      invalid_packet = %ArtNzs{
        sequence: 1,
        start_code: 0x92,
        sub_universe: 0,
        net: 0,
        length: 22,
        data: vlc_data([])
      }

      assert ArtVlc.decode(invalid_packet) ==
               {:error,
                %ArtNet.DecodeError{reason: {:invalid_data, "ArtVlc start code must be 0x91"}}}
    end

    test "rejects invalid VLC magic fields" do
      invalid_packet = packet(payload: [], data_prefix: [0x41, 0x4C, 0x44])

      assert ArtVlc.decode(invalid_packet) ==
               {:error,
                %ArtNet.DecodeError{
                  reason: {:invalid_data, "ArtVlc magic fields must be 0x41, 0x4C, 0x45"}
                }}
    end

    test "rejects ArtNzs length mismatch" do
      invalid_packet = %{packet(payload: []) | length: 21}

      assert ArtVlc.decode(invalid_packet) ==
               {:error,
                %ArtNet.DecodeError{
                  reason:
                    {:invalid_data, "ArtVlc data length does not match the ArtNzs length field"}
                }}
    end

    test "rejects payload count mismatch" do
      invalid_packet = packet(payload: [1, 2, 3], payload_count: 2)

      assert ArtVlc.decode(invalid_packet) ==
               {:error,
                %ArtNet.DecodeError{
                  reason:
                    {:invalid_data, "ArtVlc payload count does not match the payload length"}
                }}
    end

    test "rejects payload checksum mismatch" do
      invalid_packet = packet(payload: [1, 2, 3], payload_checksum: 7)

      assert ArtVlc.decode(invalid_packet) ==
               {:error,
                %ArtNet.DecodeError{
                  reason: {:invalid_data, "ArtVlc payload checksum does not match the payload"}
                }}
    end
  end

  test "checksum/1 returns the 16-bit additive checksum" do
    assert ArtVlc.checksum([0xFF, 0x02]) == 0x0101
    assert ArtVlc.checksum([0xFF, 0x02, 0xFF00]) == 0x0001
  end

  defp packet(opts) do
    data =
      Keyword.get_lazy(opts, :data, fn -> vlc_data(Keyword.get(opts, :payload, []), opts) end)

    %ArtNzs{
      sequence: 1,
      start_code: 0x91,
      sub_universe: 2,
      net: 3,
      length: length(data),
      data: data
    }
  end

  defp vlc_data(payload, opts \\ []) do
    [man_id_hi, man_id_lo, sub_code] = Keyword.get(opts, :data_prefix, [0x41, 0x4C, 0x45])
    payload_count = Keyword.get(opts, :payload_count, length(payload))
    payload_checksum = Keyword.get(opts, :payload_checksum, ArtVlc.checksum(payload))

    [
      man_id_hi,
      man_id_lo,
      sub_code,
      0b1010_0000,
      0x12,
      0x34,
      0x00,
      0x02,
      div(payload_count, 256),
      rem(payload_count, 256),
      div(payload_checksum, 256),
      rem(payload_checksum, 256),
      0,
      75,
      0x04,
      0xB0,
      0x00,
      0x02,
      0x00,
      0x01,
      0x00,
      0x1E
      | payload
    ]
  end
end
