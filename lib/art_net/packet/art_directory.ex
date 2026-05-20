defmodule ArtNet.Packet.ArtDirectory do
  use ArtNet.Packet.Schema

  defpacket do
    field(:filler, {:binary, 2}, default: <<0::size(16)>>)
    field(:command, {:integer, 8})
    field(:file, {:integer, 16})
  end
end
