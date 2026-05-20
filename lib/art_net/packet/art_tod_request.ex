defmodule ArtNet.Packet.ArtTodRequest do
  @moduledoc """
  Requests a Table of Devices for RDM discovery.

  Controllers use this packet to ask a node for discovered RDM UIDs on one or
  more ports.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:spare, {:binary, 7}, default: <<0::size(56)>>)
    field(:net, {:integer, 8}, default: 0)
    field(:command, {:enum_table, EnumTable.TodRequestCommand}, default: :tod_full)
    field(:address_count, {:integer, 8})
    field(:address, [{:integer, 8}], length: 32)
  end

  @impl ArtNet.Packet.Schema
  def validate(%{address_count: address_count}) when address_count <= 32, do: :ok
  def validate(_), do: {:error, "Address count must be 32 or less"}
end
