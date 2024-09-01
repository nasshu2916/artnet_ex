defmodule ArtNet.Packet.ArtDmx do
  use ArtNet.Packet.Schema

  defpacket op_code: 0x5000 do
    field(:sequence, :uint8, default: 0)
    field(:physical, :uint8, default: 0)
    field(:sub_universe, :uint8, default: 0)
    field(:net, :uint8, default: 0)
    field(:length, :uint16)
    field(:data, :binary, size: nil)
  end
end
