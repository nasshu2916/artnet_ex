defmodule ArtNet.Packet.ArtDirectory do
  @moduledoc """
  Requests a node's file list.

  The command and file fields select which directory information the node
  should return.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler, {:binary, 2}, default: <<0::size(16)>>)
    field(:command, {:integer, 8})
    field(:file, {:integer, 16})
  end
end
