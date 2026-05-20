defmodule ArtNet.Packet.ArtTodData do
  @moduledoc """
  Sends a Table of Devices for RDM discovery.

  Nodes use this packet to return discovered RDM UIDs and discovery response
  status to a controller.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:rdm_version, {:integer, 8}, default: 1)
    field(:port, {:integer, 8})
    field(:spare, {:binary, 6}, default: <<0::size(48)>>)
    field(:bind_index, {:integer, 8}, default: 1)
    field(:net, {:integer, 8}, default: 0)
    field(:command_response, {:enum_table, EnumTable.TodDataCommandResponse}, default: :tod_full)
    field(:address, {:integer, 8})
    field(:uid_total, {:integer, 16})
    field(:block_count, {:integer, 8}, default: 0)
    field(:uid_count, {:integer, 8})
    field(:tod, [{:binary, 6}])
  end

  @impl ArtNet.Packet.Schema
  def validate(%{uid_count: uid_count, tod: tod}) when uid_count == length(tod), do: :ok
  def validate(_), do: {:error, "ToD length does not match the uid_count field"}
end
