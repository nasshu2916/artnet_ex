defmodule ArtNet.Packet.ArtTimeSync do
  use ArtNet.Packet.Schema

  # The current Art-Net 4 specification does not define OpTimeSync payload fields,
  # so keep any trailing bytes as an opaque payload.
  defpacket do
    field(:payload, {:binary, nil}, default: <<>>)
  end
end
