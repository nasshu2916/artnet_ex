defmodule ArtNet.Packet.ArtPollReply do
  @moduledoc """
  Reports node identity, addressing, port status, and capability information.

  Nodes send this packet in response to `ArtNet.Packet.ArtPoll` and when their
  advertised state changes.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.BitField

  defpacket op_code: {:op_poll_reply, 0x2100}, require_version_header?: false do
    field(:ip_address, {:binary, 4}, description: "IPv4 address of the responding node.")

    field(:port, {:integer, 16, :little_endian},
      description: "Art-Net UDP port used by the node."
    )

    field(:version_info, {:integer, 16},
      description: "Firmware version information reported by the node."
    )

    field(:net_switch, {:integer, 8}, description: "Top 7 bits of the node Net address.")
    field(:sub_switch, {:integer, 8}, description: "Sub-Net address reported by the node.")
    field(:oem, {:integer, 16}, description: "OEM code reported by the node.")

    field(:ubea_version, {:integer, 8},
      description: "UBEA firmware version, or 0 when not present."
    )

    field(:status1, {:bit_field, BitField.Status1}, description: "Primary node status flags.")

    field(:est_amanu_facturer, {:binary, 2},
      description: "ESTA manufacturer code reported by the node."
    )

    field(:short_name, {:string, 18}, description: "Short node name.")
    field(:long_name, {:string, 64}, description: "Long node name.")
    field(:node_report, {:binary, 64}, description: "Node report status text.")
    field(:num_ports, {:integer, 16}, description: "Number of input or output ports implemented.")

    field(:port_types, [{:bit_field, BitField.PortType}],
      length: 4,
      description: "Per-port protocol and direction flags."
    )

    field(:good_input, [{:bit_field, BitField.GoodInput}],
      length: 4,
      description: "Per-input-port status flags."
    )

    field(:good_output, [{:bit_field, BitField.GoodOutput}],
      length: 4,
      description: "Per-output-port status flags."
    )

    field(:sw_in, [{:integer, 8}],
      length: 4,
      description: "Input Port-Address low byte values for each port."
    )

    field(:sw_out, [{:integer, 8}],
      length: 4,
      description: "Output Port-Address low byte values for each port."
    )

    field(:acn_priority, {:integer, 8}, description: "sACN priority reported by the node.")
    field(:sw_macro, {:integer, 8}, description: "Macro switch state reported by the node.")
    field(:sw_remote, {:integer, 8}, description: "Remote switch state reported by the node.")
    field(:spare, {:binary, 3}, description: "Reserved bytes.")
    field(:style, {:integer, 8}, description: "Node style code.")
    field(:mac_address, {:binary, 6}, description: "Node MAC address.")
    field(:bind_ip, {:binary, 4}, description: "IPv4 address of the root device for this bind.")
    field(:bind_index, {:integer, 8}, description: "Bind index of this node.")
    field(:status2, {:bit_field, BitField.Status2}, description: "Secondary node status flags.")

    field(:good_output_b, [{:bit_field, BitField.GoodOutputB}],
      length: 4,
      description: "Additional per-output-port status flags.",
      default: [
        %BitField.GoodOutputB{},
        %BitField.GoodOutputB{},
        %BitField.GoodOutputB{},
        %BitField.GoodOutputB{}
      ]
    )

    field(:status3, {:bit_field, BitField.Status3},
      default: %BitField.Status3{},
      description: "Tertiary node status flags."
    )

    field(:default_responder_uid, {:binary, 6},
      default: <<0::size(6 * 8)>>,
      description: "Default RDM responder UID for the node."
    )

    field(:user, {:integer, 16}, default: 0, description: "User-defined node value.")
    field(:refresh_rate, {:integer, 16}, default: 0, description: "DMX output refresh rate.")

    field(:background_queue_policy, {:integer, 8},
      default: 0,
      description: "Background queue policy value."
    )

    field(:filler, {:binary, 10},
      default: <<0::size(10 * 8)>>,
      description: "Reserved bytes, transmitted as zero."
    )
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
