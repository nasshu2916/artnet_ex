defmodule ArtNet.Packet.ArtPollReplyTest do
  use ExUnit.Case, async: true

  test "decode/encode" do
    [
      {
        %ArtNet.Packet.ArtPollReply{
          ip_address: <<0, 0, 0, 0>>,
          port: 6454,
          version_info: 0,
          net_switch: 0,
          sub_switch: 0,
          oem: 0,
          ubea_version: 0,
          status1: %ArtNet.Packet.BitField.Status1{
            ubea: false,
            rdm: false,
            boot_rom: false,
            port_address: :unknown,
            indicator: :unknown
          },
          est_amanu_facturer: <<0, 0>>,
          short_name: "",
          long_name: "",
          node_report: <<0::size(64 * 8)>>,
          num_ports: 0,
          port_types: [
            %ArtNet.Packet.BitField.PortType{port_type: :dmx512, input: false, output: false},
            %ArtNet.Packet.BitField.PortType{port_type: :dmx512, input: false, output: false},
            %ArtNet.Packet.BitField.PortType{port_type: :dmx512, input: false, output: false},
            %ArtNet.Packet.BitField.PortType{port_type: :dmx512, input: false, output: false}
          ],
          good_input: [
            %ArtNet.Packet.BitField.GoodInput{
              receive_errors: false,
              input_disabled: false,
              dmx_text: false,
              dmx_sip: false,
              dmx_test_packet: false,
              data_received: false
            },
            %ArtNet.Packet.BitField.GoodInput{
              receive_errors: false,
              input_disabled: false,
              dmx_text: false,
              dmx_sip: false,
              dmx_test_packet: false,
              data_received: false
            },
            %ArtNet.Packet.BitField.GoodInput{
              receive_errors: false,
              input_disabled: false,
              dmx_text: false,
              dmx_sip: false,
              dmx_test_packet: false,
              data_received: false
            },
            %ArtNet.Packet.BitField.GoodInput{
              receive_errors: false,
              input_disabled: false,
              dmx_text: false,
              dmx_sip: false,
              dmx_test_packet: false,
              data_received: false
            }
          ],
          good_output: [
            %ArtNet.Packet.BitField.GoodOutput{
              convert_sacn: false,
              marge_ltp_mode: false,
              output_short: false,
              merging: false,
              dmx_test_packet: false,
              dmx_sip: false,
              dmx_text: false,
              output_data: false
            },
            %ArtNet.Packet.BitField.GoodOutput{
              convert_sacn: false,
              marge_ltp_mode: false,
              output_short: false,
              merging: false,
              dmx_test_packet: false,
              dmx_sip: false,
              dmx_text: false,
              output_data: false
            },
            %ArtNet.Packet.BitField.GoodOutput{
              convert_sacn: false,
              marge_ltp_mode: false,
              output_short: false,
              merging: false,
              dmx_test_packet: false,
              dmx_sip: false,
              dmx_text: false,
              output_data: false
            },
            %ArtNet.Packet.BitField.GoodOutput{
              convert_sacn: false,
              marge_ltp_mode: false,
              output_short: false,
              merging: false,
              dmx_test_packet: false,
              dmx_sip: false,
              dmx_text: false,
              output_data: false
            }
          ],
          sw_in: [0, 0, 0, 0],
          sw_out: [0, 0, 0, 0],
          sw_video: 0,
          sw_macro: 0,
          sw_remote: 0,
          spare: <<0, 0, 0>>,
          style: 0,
          mac_address: <<0, 0, 0, 0, 0, 0>>,
          bind_ip: <<0, 0, 0, 0>>,
          bind_index: 0,
          status2: %ArtNet.Packet.BitField.Status2{
            support_browser: false,
            dhcp: false,
            dhcp_capable: false,
            port_15bit: false,
            can_switch: false,
            squawking: false,
            switch_output_style: false,
            control_rdm: false
          },
          filler: <<0::size(26 * 8)>>
        },
        <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x21, 0x00, 0x00, 0x00, 0x00,
          0x36, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00>>
      },
      {
        %ArtNet.Packet.ArtPollReply{
          ip_address: <<0, 0, 0, 0>>,
          port: 6454,
          version_info: 14,
          net_switch: 0,
          sub_switch: 0,
          oem: 0,
          ubea_version: 0,
          status1: %ArtNet.Packet.BitField.Status1{
            ubea: true,
            rdm: true,
            boot_rom: false,
            port_address: :front,
            indicator: :normal
          },
          est_amanu_facturer: <<0, 0>>,
          short_name: "test short name",
          long_name: "test Log Name",
          node_report: <<0::size(64 * 8)>>,
          num_ports: 0,
          port_types: [
            %ArtNet.Packet.BitField.PortType{port_type: :art_net, input: true, output: false},
            %ArtNet.Packet.BitField.PortType{port_type: :art_net, input: false, output: true},
            %ArtNet.Packet.BitField.PortType{port_type: :art_net, input: true, output: true},
            %ArtNet.Packet.BitField.PortType{port_type: :art_net, input: false, output: false}
          ],
          good_input: [
            %ArtNet.Packet.BitField.GoodInput{
              receive_errors: false,
              input_disabled: false,
              dmx_text: false,
              dmx_sip: false,
              dmx_test_packet: false,
              data_received: false
            },
            %ArtNet.Packet.BitField.GoodInput{
              receive_errors: false,
              input_disabled: false,
              dmx_text: false,
              dmx_sip: false,
              dmx_test_packet: false,
              data_received: false
            },
            %ArtNet.Packet.BitField.GoodInput{
              receive_errors: false,
              input_disabled: false,
              dmx_text: false,
              dmx_sip: false,
              dmx_test_packet: false,
              data_received: false
            },
            %ArtNet.Packet.BitField.GoodInput{
              receive_errors: false,
              input_disabled: false,
              dmx_text: false,
              dmx_sip: false,
              dmx_test_packet: false,
              data_received: false
            }
          ],
          good_output: [
            %ArtNet.Packet.BitField.GoodOutput{
              convert_sacn: false,
              marge_ltp_mode: false,
              output_short: false,
              merging: false,
              dmx_test_packet: false,
              dmx_sip: false,
              dmx_text: false,
              output_data: false
            },
            %ArtNet.Packet.BitField.GoodOutput{
              convert_sacn: false,
              marge_ltp_mode: false,
              output_short: false,
              merging: false,
              dmx_test_packet: false,
              dmx_sip: false,
              dmx_text: false,
              output_data: false
            },
            %ArtNet.Packet.BitField.GoodOutput{
              convert_sacn: false,
              marge_ltp_mode: false,
              output_short: false,
              merging: false,
              dmx_test_packet: false,
              dmx_sip: false,
              dmx_text: false,
              output_data: false
            },
            %ArtNet.Packet.BitField.GoodOutput{
              convert_sacn: false,
              marge_ltp_mode: false,
              output_short: false,
              merging: false,
              dmx_test_packet: false,
              dmx_sip: false,
              dmx_text: false,
              output_data: false
            }
          ],
          sw_in: [0, 0, 0, 0],
          sw_out: [0, 0, 0, 0],
          sw_video: 0,
          sw_macro: 0,
          sw_remote: 0,
          spare: <<0, 0, 0>>,
          style: 0,
          mac_address: <<0, 0, 0, 0, 0, 0>>,
          bind_ip: <<0, 0, 0, 0>>,
          bind_index: 0,
          status2: %ArtNet.Packet.BitField.Status2{
            support_browser: false,
            dhcp: false,
            dhcp_capable: false,
            port_15bit: false,
            can_switch: false,
            squawking: false,
            switch_output_style: false,
            control_rdm: false
          },
          filler: <<0::size(26 * 8)>>
        },
        <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x21, 0x00, 0x00, 0x00, 0x00,
          0x36, 0x19, 0x00, 0x0E, 0x00, 0x00, 0x00, 0x00, 0x00, 0xD3, 0x00, 0x00, 0x74, 0x65,
          0x73, 0x74, 0x20, 0x73, 0x68, 0x6F, 0x72, 0x74, 0x20, 0x6E, 0x61, 0x6D, 0x65, 0x00,
          0x00, 0x00, 0x74, 0x65, 0x73, 0x74, 0x20, 0x4C, 0x6F, 0x67, 0x20, 0x4E, 0x61, 0x6D,
          0x65, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x45, 0x85, 0xC5, 0x05, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00>>
      }
    ]
    |> Enum.each(fn {packet, data} ->
      assert ArtNet.Packet.ArtPollReply.decode(data) == {:ok, packet}
      assert ArtNet.Packet.ArtPollReply.encode(packet) == {:ok, data}
    end)
  end
end
