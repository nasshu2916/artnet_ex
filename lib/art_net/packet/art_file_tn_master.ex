defmodule ArtNet.Packet.ArtFileTnMaster do
  @moduledoc """
  Uploads a user file to a node.

  The packet carries file transfer type, block identifiers, and one data block.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:type, {:integer, 8}, description: "File transfer command type.")
    field(:block_id, {:integer, 8}, description: "Sequential block identifier for the transfer.")
    field(:length, {:integer, 32}, description: "Total file length in bytes.")
    field(:name, {:string, 14}, description: "File name associated with the transfer.")
    field(:checksum, {:integer, 16}, description: "Checksum for the file transfer block.")

    field(:spare, {:binary, 4},
      default: <<0::size(32)>>,
      description: "Reserved bytes, transmitted as zero."
    )

    field(:data, {:binary, 512}, description: "File transfer data block.")
  end
end
