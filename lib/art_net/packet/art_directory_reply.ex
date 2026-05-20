defmodule ArtNet.Packet.ArtDirectoryReply do
  use ArtNet.Packet.Schema

  defpacket do
    field(:filler, {:binary, 2}, default: <<0::size(16)>>)
    field(:flags, {:integer, 8})
    field(:file, {:integer, 16})
    field(:name, {:string, 16})
    field(:description, {:string, 64})
    field(:length, {:integer, 64})
    field(:data, {:binary, 64})
  end
end
