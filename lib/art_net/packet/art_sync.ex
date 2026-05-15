defmodule ArtNet.Packet.ArtSync do
  use ArtNet.Packet.Schema

  defpacket do
    field(:aux1, {:integer, 8}, default: 0)
    field(:aux2, {:integer, 8}, default: 0)
  end
end
