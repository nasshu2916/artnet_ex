defmodule ArtNet.Packet.ArtFileFnMaster do
  @moduledoc """
  Requests a user file download from a node.

  The current schema has no payload fields and is kept for OpCode coverage.
  """

  use ArtNet.Packet.Schema

  defpacket do
  end
end
