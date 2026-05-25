defmodule ArtNet.Packet.ArtSync do
  @moduledoc """
  Synchronizes output of previously received DMX packets.

  Controllers send this packet to force nodes to transfer buffered `ArtDmx`
  packets to their outputs at the same time.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:aux1, {:integer, 8},
      default: 0,
      description: "Reserved auxiliary byte, transmitted as zero."
    )

    field(:aux2, {:integer, 8},
      default: 0,
      description: "Reserved auxiliary byte, transmitted as zero."
    )
  end
end
