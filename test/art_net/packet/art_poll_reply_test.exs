defmodule ArtNet.Packet.ArtPollReplyTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.ArtPollReply
  alias ArtNet.Packet.BitField

  test "decode/encode round-trips Art-Net 4 fields" do
    packet =
      poll_reply(
        good_output_b: [
          %BitField.GoodOutputB{
            background_discovery_disabled: true,
            discovery_not_running: false,
            continuous_output_style: true,
            rdm_disabled: false
          },
          %BitField.GoodOutputB{
            background_discovery_disabled: false,
            discovery_not_running: true,
            continuous_output_style: false,
            rdm_disabled: true
          },
          %BitField.GoodOutputB{},
          %BitField.GoodOutputB{rdm_disabled: true}
        ],
        status3: %BitField.Status3{
          background_discovery_control: true,
          background_queue: true,
          rdmnet: true,
          port_direction_switch: false,
          llrp: true,
          programmable_failsafe: true,
          failsafe_state: :playback_scene
        },
        default_responder_uid: <<1, 2, 3, 4, 5, 6>>,
        user: 0x1234,
        refresh_rate: 120,
        background_queue_policy: 3
      )

    assert {:ok, data} = ArtPollReply.encode(packet)

    assert <<"Art-Net", 0, 0x00, 0x21, body::binary>> = data

    assert body ==
             <<0x00, 0x00, 0x00, 0x00, 0x36, 0x19, 0x00, 0x0E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
               0x00, 0x00, "test short name", 0::size(3 * 8), "test long name", 0::size(50 * 8),
               0::size(64 * 8), 0::size(41 * 8), 0x50, 0xA0, 0x00, 0x80, 0xF7, 0x01, 0x02, 0x03,
               0x04, 0x05, 0x06, 0x12, 0x34, 0x00, 0x78, 0x03, 0::size(10 * 8)>>

    assert byte_size(data) == 239
    assert ArtPollReply.decode(data) == {:ok, packet}
  end

  test "decode pads the 207 byte minimum packet fields with zero" do
    packet = poll_reply()
    assert {:ok, data} = ArtPollReply.encode(packet)

    minimum_data = binary_part(data, 0, 207)

    assert ArtPollReply.decode(minimum_data) == {:ok, packet}
  end

  test "encode applies defaults for Art-Net 4 reserved fields" do
    packet = struct!(ArtPollReply, Keyword.delete(poll_reply_params(), :filler))

    assert {:ok, data} = ArtPollReply.encode(packet)
    assert binary_part(data, 229, 10) == <<0::size(10 * 8)>>
  end

  test "validate rejects malformed Art-Net 4 list lengths" do
    packet = poll_reply(good_output_b: [%BitField.GoodOutputB{}])

    assert ArtPollReply.encode(packet) ==
             {:error,
              %ArtNet.EncodeError{
                reason: {:invalid_data, "good_output_b must contain 4 values, got 1"}
              }}
  end

  test "validate rejects invalid background queue policy values" do
    packet = poll_reply(background_queue_policy: 16)

    assert ArtPollReply.encode(packet) ==
             {:error,
              %ArtNet.EncodeError{
                reason: {:invalid_data, "background_queue_policy must be in the range 0..15"}
              }}
  end

  test "decode does not apply encode-only background queue policy validation" do
    assert {:ok, data} = ArtPollReply.encode(poll_reply())
    <<prefix::binary-size(228), _background_queue_policy, suffix::binary>> = data
    invalid_data = <<prefix::binary, 16, suffix::binary>>

    assert {:ok, packet} = ArtPollReply.decode(invalid_data)
    assert packet.background_queue_policy == 16
  end

  defp poll_reply(overrides \\ []) do
    struct!(ArtPollReply, Keyword.merge(poll_reply_params(), overrides))
  end

  defp poll_reply_params do
    [
      ip_address: <<0, 0, 0, 0>>,
      port: 6454,
      version_info: 14,
      net_switch: 0,
      sub_switch: 0,
      oem: 0,
      ubea_version: 0,
      status1: %BitField.Status1{
        ubea: false,
        rdm: false,
        boot_rom: false,
        port_address: :unknown,
        indicator: :unknown
      },
      est_amanu_facturer: <<0, 0>>,
      short_name: "test short name",
      long_name: "test long name",
      node_report: <<0::size(64 * 8)>>,
      num_ports: 0,
      port_types: zero_port_types(),
      good_input: zero_good_input(),
      good_output: zero_good_output(),
      sw_in: [0, 0, 0, 0],
      sw_out: [0, 0, 0, 0],
      acn_priority: 0,
      sw_macro: 0,
      sw_remote: 0,
      spare: <<0, 0, 0>>,
      style: 0,
      mac_address: <<0, 0, 0, 0, 0, 0>>,
      bind_ip: <<0, 0, 0, 0>>,
      bind_index: 0,
      status2: %BitField.Status2{
        support_browser: false,
        dhcp: false,
        dhcp_capable: false,
        port_15bit: false,
        can_switch: false,
        squawking: false,
        switch_output_style: false,
        control_rdm: false
      },
      good_output_b: zero_good_output_b(),
      status3: %BitField.Status3{},
      default_responder_uid: <<0::size(6 * 8)>>,
      user: 0,
      refresh_rate: 0,
      background_queue_policy: 0,
      filler: <<0::size(10 * 8)>>
    ]
  end

  defp zero_port_types do
    Enum.map(1..4, fn _ ->
      %BitField.PortType{port_type: :dmx512, input: false, output: false}
    end)
  end

  defp zero_good_input do
    Enum.map(1..4, fn _ ->
      %BitField.GoodInput{
        convert_sacn: false,
        receive_errors: false,
        input_disabled: false,
        dmx_text: false,
        dmx_sip: false,
        dmx_test_packet: false,
        data_received: false
      }
    end)
  end

  defp zero_good_output do
    Enum.map(1..4, fn _ ->
      %BitField.GoodOutput{
        convert_sacn: false,
        merge_ltp_mode: false,
        output_short: false,
        merging: false,
        dmx_test_packet: false,
        dmx_sip: false,
        dmx_text: false,
        output_data: false
      }
    end)
  end

  defp zero_good_output_b do
    Enum.map(1..4, fn _ -> %BitField.GoodOutputB{} end)
  end
end
