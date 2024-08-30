defmodule ArtNet.Packet.ArtDmx do
  use ArtNet.Packet.Schema

  defpacket sequence: {:integer, default: 0, size: 8},
            physical: {:integer, default: 0, size: 8},
            sub_universe: {:integer, size: 8},
            net: {:integer, size: 8},
            length: {:integer, size: 16},
            data: {:binary, size: nil}
end
