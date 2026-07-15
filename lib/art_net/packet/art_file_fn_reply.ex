defmodule ArtNet.Packet.ArtFileFnReply do
  @moduledoc """
  Acknowledges file download packets.

  The current schema has no payload fields and is kept for OpCode coverage.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: 0xF600 do
  end
end
