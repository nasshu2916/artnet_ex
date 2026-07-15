defmodule ArtNet.Packet.ArtRdm do
  @moduledoc """
  Carries non-discovery RDM messages over Art-Net.

  Use this packet for RDM traffic that is not part of the RDM discovery
  process.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket op_code: 0x8300 do
    field(:rdm_version, {:integer, 8}, default: 1, description: "RDM protocol version.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")

    field(:spare, {:binary, 5},
      default: <<0::size(40)>>,
      description: "Reserved bytes, transmitted as zero."
    )

    field(:fifo_available, {:integer, 8},
      default: 0,
      description: "Number of RDM messages available in the node FIFO."
    )

    field(:fifo_max, {:integer, 8}, default: 0, description: "Maximum RDM FIFO capacity.")

    field(:net, {:integer, 8},
      default: 0,
      description: "Bits 8-14 of the 15-bit Port-Address."
    )

    field(:command, {:enum_table, EnumTable.RdmCommand},
      default: :ar_process,
      description: "RDM command action."
    )

    field(:address, {:integer, 8}, description: "Low byte of the target Port-Address.")
    field(:rdm_packet, [{:integer, 8}], description: "Embedded RDM packet bytes.")
  end
end
