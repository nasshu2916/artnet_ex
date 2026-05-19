defmodule ArtNet.Packet.ArtPollReply do
  use ArtNet.Packet.Schema

  alias ArtNet.Packet.BitField

  defpacket require_version_header?: false do
    field(:ip_address, {:binary, 4})
    field(:port, {:integer, 16, :little_endian})
    field(:version_info, {:integer, 16})
    field(:net_switch, {:integer, 8})
    field(:sub_switch, {:integer, 8})
    field(:oem, {:integer, 16})
    field(:ubea_version, {:integer, 8})
    field(:status1, {:bit_field, BitField.Status1})
    field(:est_amanu_facturer, {:binary, 2})
    field(:short_name, {:string, 18})
    field(:long_name, {:string, 64})
    field(:node_report, {:binary, 64})
    field(:num_ports, {:integer, 16})
    field(:port_types, [{:bit_field, BitField.PortType}], length: 4)
    field(:good_input, [{:bit_field, BitField.GoodInput}], length: 4)
    field(:good_output, [{:bit_field, BitField.GoodOutput}], length: 4)
    field(:sw_in, [{:integer, 8}], length: 4)
    field(:sw_out, [{:integer, 8}], length: 4)
    field(:acn_priority, {:integer, 8})
    field(:sw_macro, {:integer, 8})
    field(:sw_remote, {:integer, 8})
    field(:spare, {:binary, 3})
    field(:style, {:integer, 8})
    field(:mac_address, {:binary, 6})
    field(:bind_ip, {:binary, 4})
    field(:bind_index, {:integer, 8})
    field(:status2, {:bit_field, BitField.Status2})

    field(:good_output_b, [{:bit_field, BitField.GoodOutputB}],
      length: 4,
      default: [
        %BitField.GoodOutputB{},
        %BitField.GoodOutputB{},
        %BitField.GoodOutputB{},
        %BitField.GoodOutputB{}
      ]
    )

    field(:status3, {:bit_field, BitField.Status3}, default: %BitField.Status3{})
    field(:default_responder_uid, {:binary, 6}, default: <<0::size(6 * 8)>>)
    field(:user, {:integer, 16}, default: 0)
    field(:refresh_rate, {:integer, 16}, default: 0)
    field(:background_queue_policy, {:integer, 8}, default: 0)
    field(:filler, {:binary, 10}, default: <<0::size(10 * 8)>>)
  end

  @impl ArtNet.Packet.Schema
  def pre_decode(body), do: ArtNet.Misc.pad_binary(body, 229, 191)

  @impl ArtNet.Packet.Schema
  def validate_encode(%__MODULE__{} = packet) do
    validate_background_queue_policy(packet.background_queue_policy)
  end

  defp validate_background_queue_policy(value)
       when is_integer(value) and value >= 0 and value <= 15 do
    :ok
  end

  defp validate_background_queue_policy(_value) do
    {:error, "background_queue_policy must be in the range 0..15"}
  end
end
