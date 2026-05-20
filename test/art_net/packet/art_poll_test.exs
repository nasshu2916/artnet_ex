defmodule ArtNet.Packet.ArtPollTest do
  use ExUnit.Case, async: true

  test "decode/encode" do
    [
      {
        %ArtNet.Packet.ArtPoll{
          talk_to_me: %ArtNet.Packet.BitField.TalkToMe{
            reply_on_change: false,
            diagnostics: false,
            diag_unicast: false,
            vlc: false,
            targeted_mode: false
          },
          priority: :dp_all,
          target_port_address_top: 0,
          target_port_address_bottom: 0,
          esta_manufacturer: 0,
          oem: 0
        },
        <<0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>
      },
      {
        %ArtNet.Packet.ArtPoll{
          talk_to_me: %ArtNet.Packet.BitField.TalkToMe{
            reply_on_change: true,
            diagnostics: true,
            diag_unicast: true,
            vlc: false,
            targeted_mode: true
          },
          priority: :dp_high,
          target_port_address_top: 0x7FFF,
          target_port_address_bottom: 0x1234,
          esta_manufacturer: 0x414C,
          oem: 0x1234
        },
        <<0x2E, 0x80, 0x7F, 0xFF, 0x12, 0x34, 0x41, 0x4C, 0x12, 0x34>>
      }
    ]
    |> Enum.each(fn {packet, body} ->
      data = <<"Art-Net", 0, 0x00, 0x20, 0x00, 0x0E, body::binary>>

      assert ArtNet.Packet.ArtPoll.decode(data) == {:ok, packet}
      assert {:ok, encoded} = ArtNet.Packet.ArtPoll.encode(packet)
      assert <<"Art-Net", 0, 0x00, 0x20, 0x00, 0x0E, encoded_body::binary>> = encoded
      assert encoded_body == body
    end)
  end

  test "decode pads legacy minimum packet fields with zero" do
    data = <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x20, 0x00, 0x0E, 0x00, 0x00>>

    assert ArtNet.Packet.ArtPoll.decode(data) ==
             {:ok,
              %ArtNet.Packet.ArtPoll{
                talk_to_me: %ArtNet.Packet.BitField.TalkToMe{
                  reply_on_change: false,
                  diagnostics: false,
                  diag_unicast: false,
                  vlc: false,
                  targeted_mode: false
                },
                priority: :dp_all,
                target_port_address_top: 0,
                target_port_address_bottom: 0,
                esta_manufacturer: 0,
                oem: 0
              }}
  end

  test "decode rejects bodies shorter than the legacy minimum fields" do
    data = <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x20, 0x00, 0x0E, 0x00>>

    assert ArtNet.Packet.ArtPoll.decode(data) ==
             {:error, %ArtNet.DecodeError{reason: {:decode_error, :priority}}}
  end

  test "validate rejects invalid target Port-Address values" do
    packet = %ArtNet.Packet.ArtPoll{
      talk_to_me: %ArtNet.Packet.BitField.TalkToMe{
        reply_on_change: true,
        diagnostics: true,
        diag_unicast: true,
        vlc: false,
        targeted_mode: true
      },
      target_port_address_top: 0x8000
    }

    assert ArtNet.Packet.ArtPoll.encode(packet) ==
             {:error,
              %ArtNet.EncodeError{
                reason: {:invalid_data, "target_port_address_top must be a 15-bit Port-Address"}
              }}
  end

  test "new applies encode-only validation" do
    assert ArtNet.Packet.ArtPoll.new(
             talk_to_me: %ArtNet.Packet.BitField.TalkToMe{
               reply_on_change: false,
               diagnostics: false,
               diag_unicast: false,
               vlc: false,
               targeted_mode: false
             },
             target_port_address_top: 0x8000
           ) ==
             {:error,
              %ArtNet.EncodeError{
                reason: {:invalid_data, "target_port_address_top must be a 15-bit Port-Address"}
              }}
  end

  test "decode does not apply encode-only target Port-Address validation" do
    body = <<0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>
    data = <<"Art-Net", 0, 0x00, 0x20, 0x00, 0x0E, body::binary>>

    assert ArtNet.Packet.ArtPoll.decode(data) ==
             {:ok,
              %ArtNet.Packet.ArtPoll{
                talk_to_me: %ArtNet.Packet.BitField.TalkToMe{
                  reply_on_change: false,
                  diagnostics: false,
                  diag_unicast: false,
                  vlc: false,
                  targeted_mode: false
                },
                priority: :dp_all,
                target_port_address_top: 0x8000,
                target_port_address_bottom: 0,
                esta_manufacturer: 0,
                oem: 0
              }}
  end

  test "decode error" do
    data = <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x20, 0x00, 0x0E, 0x0E, 0x01>>

    assert ArtNet.Packet.ArtPoll.decode(data) ==
             {:error, %ArtNet.DecodeError{reason: {:decode_error, :priority}}}
  end

  test "decode zero-filled filler" do
    data =
      <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x20, 0x00, 0x0E, 0x00, 0x00,
        0::size(8 * 8)>>

    assert ArtNet.Packet.ArtPoll.decode(data) ==
             {:ok,
              %ArtNet.Packet.ArtPoll{
                talk_to_me: %ArtNet.Packet.BitField.TalkToMe{
                  reply_on_change: false,
                  diagnostics: false,
                  diag_unicast: false,
                  vlc: false
                },
                priority: :dp_all
              }}
  end

  test "encode error" do
    packet = %ArtNet.Packet.ArtPoll{
      talk_to_me: %ArtNet.Packet.BitField.TalkToMe{
        reply_on_change: true,
        diagnostics: true,
        diag_unicast: true,
        vlc: false,
        targeted_mode: false
      },
      priority: :invalid
    }

    assert {:error,
            %ArtNet.EncodeError{
              reason:
                {:encode_error,
                 %{
                   type: {:enum_table, ArtNet.Packet.EnumTable.Priority},
                   value: :invalid,
                   key: :priority
                 }}
            }} = ArtNet.Packet.ArtPoll.encode(packet)
  end
end
