defmodule ArtNet.Packet.ArtPollReply do
  use ArtNet.Packet.Schema

  defpacket op_code: 0x2100, require_version_header?: false do
    field(:ip_address, {:binary, 4})
    field(:port, {:integer, 16, :little_endian})
    field(:version_info, :uint16)
    field(:net_switch, :uint8)
    field(:sub_switch, :uint8)
    field(:oem, :uint16)
    field(:ubea_version, :uint8)
    field(:status1, :uint8)
    field(:est_amanu_facturer, {:binary, 2})
    field(:short_name, {:string, 18})
    field(:long_name, {:string, 64})
    field(:node_report, {:binary, 64})
    field(:num_ports, :uint16)
    field(:port_types, [:uint8], length: 4)
    field(:good_input, [:uint8], length: 4)
    field(:good_output, [:uint8], length: 4)
    field(:sw_in, [:uint8], length: 4)
    field(:sw_out, [:uint8], length: 4)
    field(:sw_video, :uint8)
    field(:sw_macro, :uint8)
    field(:sw_remote, :uint8)
    field(:spare, {:binary, 3})
    field(:style, :uint8)
    field(:mac_address, {:binary, 6})
    field(:bind_ip, {:binary, 4})
    field(:bind_index, :uint8)
    field(:status2, :uint8)
    field(:filler, {:binary, 26})
  end
end
