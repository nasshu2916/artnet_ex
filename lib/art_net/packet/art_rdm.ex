defmodule ArtNet.Packet.ArtRdm do
  @moduledoc """
  Carries non-discovery RDM messages over Art-Net.

  Use this packet for RDM traffic that is not part of the RDM discovery
  process.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:rdm_version, {:integer, 8}, default: 1)
    field(:filler2, {:integer, 8}, default: 0)
    field(:spare, {:binary, 5}, default: <<0::size(40)>>)
    field(:fifo_available, {:integer, 8}, default: 0)
    field(:fifo_max, {:integer, 8}, default: 0)
    field(:net, {:integer, 8}, default: 0)
    field(:command, {:enum_table, EnumTable.RdmCommand}, default: :ar_process)
    field(:address, {:integer, 8})
    field(:rdm_packet, [{:integer, 8}])
  end
end
