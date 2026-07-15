defmodule ArtNet.Packet.ArtDirectoryReply do
  @moduledoc """
  Replies to `ArtNet.Packet.ArtDirectory` with file list information.

  The payload describes a file entry, including name, description, length, and
  data metadata.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: 0x9B00 do
    field(:filler, {:binary, 2},
      default: <<0::size(16)>>,
      description: "Reserved bytes, transmitted as zero."
    )

    field(:flags, {:integer, 8}, description: "Directory entry status flags.")
    field(:file, {:integer, 16}, description: "Directory file index for this entry.")
    field(:name, {:string, 16}, description: "Directory entry file name.")
    field(:description, {:string, 64}, description: "Human-readable directory entry description.")
    field(:length, {:integer, 64}, description: "Length of the directory entry data in bytes.")
    field(:data, {:binary, 64}, description: "Directory entry data block.")
  end
end
