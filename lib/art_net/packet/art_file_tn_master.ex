defmodule ArtNet.Packet.ArtFileTnMaster do
  @moduledoc """
  Uploads a user file to a node.

  The packet carries file transfer type, block identifiers, and one data block.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:type, {:integer, 8})
    field(:block_id, {:integer, 8})
    field(:length, {:integer, 32})
    field(:name, {:string, 14})
    field(:checksum, {:integer, 16})
    field(:spare, {:binary, 4}, default: <<0::size(32)>>)
    field(:data, {:binary, 512})
  end
end
