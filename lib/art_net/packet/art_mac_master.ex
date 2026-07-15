defmodule ArtNet.Packet.ArtMacMaster do
  @moduledoc """
  Represents the deprecated ArtMacMaster packet.

  The current schema has no payload fields and is kept for OpCode coverage.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: 0xF000 do
  end
end
