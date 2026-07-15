defmodule ArtNet.Packet.ArtMacSlave do
  @moduledoc """
  Represents the deprecated ArtMacSlave packet.

  The current schema has no payload fields and is kept for OpCode coverage.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: {:op_mac_slave, 0xF100} do
  end
end
