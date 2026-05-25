defmodule ArtNet.Packet.ArtDirectory do
  @moduledoc """
  Requests a node's file list.

  The command and file fields select which directory information the node
  should return.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler, {:binary, 2},
      default: <<0::size(16)>>,
      description: "Reserved bytes, transmitted as zero."
    )

    field(:command, {:integer, 8}, description: "Directory command to execute.")
    field(:file, {:integer, 16}, description: "Directory file index referenced by the command.")
  end
end
