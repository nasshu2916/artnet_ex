defmodule ArtNet.Packet.ArtPollReply do
  use ArtNet.Packet.Schema

  defpacket op_code: 0x2100, except_version_header?: true do
    field(:ip_address, :binary, size: 4)
    field(:port, :uint16)
    field(:version_info, :uint16)
    field(:net_switch, :uint8)
    field(:sub_switch, :uint8)
    field(:oem, :uint16)
    field(:ubea_version, :uint8)
    field(:status1, :uint8)
    field(:est_amanu_facturer, :binary, size: 2)
    field(:short_name, :binary, size: 18)
    field(:long_name, :binary, size: 64)
    field(:node_report, :binary, size: 64)
    field(:num_ports, :uint16)
    field(:port_types, :binary, size: 4)
    field(:good_input, :binary, size: 4)
    field(:good_output, :binary, size: 4)
    field(:sw_in, :binary, size: 4)
    field(:sw_out, :binary, size: 4)
    field(:sw_video, :uint8)
    field(:sw_macro, :uint8)
    field(:sw_remote, :uint8)
    field(:spare, :binary, size: 3)
    field(:style, :uint8)
    field(:mac_address, :binary, size: 6)
    field(:bind_ip, :binary, size: 4)
    field(:bind_index, :uint8)
    field(:status2, :uint8)
    field(:filler, :binary, size: 26)
  end
end
