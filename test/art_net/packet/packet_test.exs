defmodule ArtNet.PacketTest do
  use ExUnit.Case
  alias ArtNet.Packet
  alias ArtNet.DecodeError
  alias ArtNet.EncodeError
  alias ArtNet.Packet.{ArtDmx, ArtPoll}

  describe "decode/2" do
    test "can decode valid ArtDmx packet" do
      data = <<"Art-Net", 0, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>
      assert {:ok, packet} = Packet.decode(ArtDmx, data)
      assert packet.sequence == 1
      assert packet.physical == 0
      assert packet.sub_universe == 0
      assert packet.net == 0
      assert packet.length == 1
      assert packet.data == [255]
    end

    test "can decode valid ArtPoll packet" do
      data =
        <<"Art-Net", 0, 0x00, 0x20, 0x00, 0x0E, 0x2E, 0x80, 0x7F, 0xFF, 0x12, 0x34, 0x41, 0x4C,
          0x12, 0x34>>

      assert {:ok, packet} = Packet.decode(ArtPoll, data)
      assert packet.talk_to_me.reply_on_change == true
      assert packet.talk_to_me.diagnostics == true
      assert packet.talk_to_me.diag_unicast == true
      assert packet.talk_to_me.vlc == false
      assert packet.talk_to_me.targeted_mode == true
      assert packet.priority == :dp_high
      assert packet.target_port_address_top == 0x7FFF
      assert packet.target_port_address_bottom == 0x1234
      assert packet.esta_manufacturer == 0x414C
      assert packet.oem == 0x1234
    end

    test "returns error for invalid identifier" do
      data = <<"Invalid", 0, 0x00, 0x50, 0x0E, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>

      assert {:error, %DecodeError{reason: {:invalid_data, "Invalid identifier"}}} =
               Packet.decode(ArtDmx, data)
    end

    test "returns error for invalid operation code" do
      data = <<"Art-Net", 0, 0x00, 0x00, 0x0E, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>

      assert {:error, %DecodeError{reason: {:invalid_data, "Invalid op code"}}} =
               Packet.decode(ArtDmx, data)
    end

    test "returns error for invalid version" do
      data = <<"Art-Net", 0, 0x00, 0x50, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>

      assert {:error, %DecodeError{reason: {:invalid_data, "Invalid version"}}} =
               Packet.decode(ArtDmx, data)
    end
  end

  describe "encode/1" do
    test "can encode valid ArtDmx packet" do
      packet = %ArtDmx{
        sequence: 1,
        physical: 0,
        sub_universe: 0,
        net: 0,
        length: 1,
        data: [255]
      }

      assert {:ok, encoded} = Packet.encode(packet)

      assert encoded ==
               <<"Art-Net", 0, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>
    end

    test "can encode valid ArtPoll packet" do
      packet = %ArtPoll{
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
      }

      assert {:ok, encoded} = Packet.encode(packet)

      assert encoded ==
               <<"Art-Net", 0, 0x00, 0x20, 0x00, 0x0E, 0x2E, 0x80, 0x7F, 0xFF, 0x12, 0x34, 0x41,
                 0x4C, 0x12, 0x34>>
    end

    test "returns error for non-struct data" do
      assert {:error, %EncodeError{reason: {:invalid_data, "packet is not a struct"}}} =
               Packet.encode("invalid")
    end

    test "handles encoding errors appropriately" do
      # Create a packet with invalid data
      packet = %ArtDmx{
        sequence: 1,
        physical: 0,
        sub_universe: 0,
        net: 0,
        length: 1,
        # Invalid DMX value (must be 0-255)
        data: [0xFFFF]
      }

      assert {:error, %EncodeError{reason: {:encode_error, _}}} = Packet.encode(packet)
    end
  end
end
