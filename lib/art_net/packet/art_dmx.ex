defmodule ArtNet.Packet.ArtDmx do
  use ArtNet.Packet.Schema

  defpacket op_code: 0x5000 do
    field(:sequence, :integer, default: 0, size: 8)
    field(:physical, :integer, default: 0, size: 8)
    field(:sub_universe, :integer, default: 0, size: 8)
    field(:net, :integer, default: 0, size: 8)
    field(:length, :integer, size: 16)
    field(:data, :binary, size: nil)
  end
end
