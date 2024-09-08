defmodule ArtNet.Packet.ArtPollReply do
  use ArtNet.Packet.Schema

  alias ArtNet.Packet.BitField

  defpacket op_code: 0x2100, require_version_header?: false do
    field(:ip_address, {:binary, 4})
    field(:port, {:integer, 16, :little_endian})
    field(:version_info, {:integer, 16})
    field(:net_switch, {:integer, 8})
    field(:sub_switch, {:integer, 8})
    field(:oem, {:integer, 16})
    field(:ubea_version, {:integer, 8})
    field(:status1, {:integer, 8})
    field(:est_amanu_facturer, {:binary, 2})
    field(:short_name, {:string, 18})
    field(:long_name, {:string, 64})
    field(:node_report, {:binary, 64})
    field(:num_ports, {:integer, 16})
    field(:port_types, [{:bit_field, BitField.PortType}], length: 4)
    field(:good_input, [{:integer, 8}], length: 4)
    field(:good_output, [{:integer, 8}], length: 4)
    field(:sw_in, [{:integer, 8}], length: 4)
    field(:sw_out, [{:integer, 8}], length: 4)
    field(:sw_video, {:integer, 8})
    field(:sw_macro, {:integer, 8})
    field(:sw_remote, {:integer, 8})
    field(:spare, {:binary, 3})
    field(:style, {:integer, 8})
    field(:mac_address, {:binary, 6})
    field(:bind_ip, {:binary, 4})
    field(:bind_index, {:integer, 8})
    field(:status2, {:integer, 8})
    field(:filler, {:binary, 26})
  end
end
