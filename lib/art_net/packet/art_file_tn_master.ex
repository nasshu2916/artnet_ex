defmodule ArtNet.Packet.ArtFileTnMaster do
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
