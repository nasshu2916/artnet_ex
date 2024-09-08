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
            vlc: false
          },
          priority: :dp_all
        },
        <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x20, 0x00, 0x0E, 0x00, 0x00>>
      },
      {
        %ArtNet.Packet.ArtPoll{
          talk_to_me: %ArtNet.Packet.BitField.TalkToMe{
            reply_on_change: true,
            diagnostics: true,
            diag_unicast: true,
            vlc: false
          },
          priority: :dp_high
        },
        <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x20, 0x00, 0x0E, 0x0E, 0xC0>>
      }
    ]
    |> Enum.each(fn {packet, data} ->
      assert ArtNet.Packet.ArtPoll.decode(data) == {:ok, packet}
      assert ArtNet.Packet.ArtPoll.encode(packet) == {:ok, data}
    end)
  end

  test "decode error" do
    data = <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x20, 0x00, 0x0E, 0x0E, 0x01>>

    assert ArtNet.Packet.ArtPoll.decode(data) ==
             {:error, %ArtNet.DecodeError{reason: {:decode_error, :priority}}}
  end

  test "encode error" do
    packet = %ArtNet.Packet.ArtPoll{
      talk_to_me: %ArtNet.Packet.BitField.TalkToMe{
        reply_on_change: true,
        diagnostics: true,
        diag_unicast: true,
        vlc: false
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
