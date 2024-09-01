defmodule ArtNet.Packet.ArtPoll do
  use ArtNet.Packet.Schema

  defpacket op_code: 0x2000 do
    field(:take_to_me, :uint8, default: 0)
    field(:priority, :uint8, default: 0x10)
  end
end
