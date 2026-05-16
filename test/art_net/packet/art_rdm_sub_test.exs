defmodule ArtNet.Packet.ArtRdmSubTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtRdmSub

  describe "encode/1 and decode/1" do
    test "encodes and decodes ArtRdmSub packets" do
      packet = %ArtRdmSub{
        rdm_version: 1,
        filler2: 0,
        uid: <<1, 2, 3, 4, 5, 6>>,
        spare1: 0,
        command_class: :set_command,
        parameter_id: 0x1234,
        sub_device: 1,
        sub_count: 2,
        spare: <<0::size(32)>>,
        data: [0x0102, 0x0304]
      }

      binary =
        <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x84, 0x00, 0x0E, 0x01, 0x00,
          0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x00, 0x30, 0x12, 0x34, 0x00, 0x01, 0x00, 0x02,
          0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04>>

      assert ArtNet.encode(packet) == {:ok, binary}
      assert ArtNet.decode(binary) == {:ok, packet}
    end

    test "rejects zero SubCount" do
      packet = %ArtRdmSub{
        rdm_version: 1,
        filler2: 0,
        uid: <<1, 2, 3, 4, 5, 6>>,
        spare1: 0,
        command_class: :set_command,
        parameter_id: 0x1234,
        sub_device: 1,
        sub_count: 0,
        spare: <<0::size(32)>>,
        data: []
      }

      assert {:error, %ArtNet.EncodeError{reason: {:invalid_data, _}}} = ArtNet.encode(packet)
    end
  end

  describe "validate/1" do
    test "accepts command classes with the current Art-Net data lengths" do
      packet = %ArtRdmSub{
        rdm_version: 1,
        filler2: 0,
        uid: <<1, 2, 3, 4, 5, 6>>,
        spare1: 0,
        command_class: :set_command,
        parameter_id: 0x1234,
        sub_device: 1,
        sub_count: 2,
        spare: <<0::size(32)>>,
        data: [0x0102, 0x0304]
      }

      assert ArtRdmSub.validate(packet) == :ok
      assert ArtRdmSub.validate(%{packet | command_class: :get_response}) == :ok
      assert ArtRdmSub.validate(%{packet | command_class: :get_command, data: []}) == :ok
      assert ArtRdmSub.validate(%{packet | command_class: :set_response, data: []}) == :ok
    end

    test "rejects data lengths that do not match command class and SubCount" do
      packet = %ArtRdmSub{
        rdm_version: 1,
        filler2: 0,
        uid: <<1, 2, 3, 4, 5, 6>>,
        spare1: 0,
        command_class: :set_command,
        parameter_id: 0x1234,
        sub_device: 1,
        sub_count: 2,
        spare: <<0::size(32)>>,
        data: [0x0102]
      }

      assert ArtRdmSub.validate(packet) ==
               {:error, "Data length does not match the command class and sub_count fields"}

      assert ArtRdmSub.validate(%{packet | command_class: :get_command}) ==
               {:error, "Data length does not match the command class and sub_count fields"}

      assert ArtRdmSub.validate(%{packet | command_class: :set_response}) ==
               {:error, "Data length does not match the command class and sub_count fields"}
    end

    test "rejects command classes outside ArtRdmSub" do
      packet = %ArtRdmSub{
        rdm_version: 1,
        filler2: 0,
        uid: <<1, 2, 3, 4, 5, 6>>,
        spare1: 0,
        command_class: :discovery_command,
        parameter_id: 0x1234,
        sub_device: 1,
        sub_count: 1,
        spare: <<0::size(32)>>,
        data: []
      }

      assert ArtRdmSub.validate(packet) ==
               {:error, "CommandClass must be Get, Set, GetResponse, or SetResponse"}
    end
  end
end
