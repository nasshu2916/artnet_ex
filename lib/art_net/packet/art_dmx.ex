defmodule ArtNet.Packet.ArtDmx do
  use ArtNet.Packet.Schema

  defpacket sequence: :integer,
            physical: :integer,
            sub_universe: :integer,
            net: :integer,
            length: :integer,
            data: :binary
end
