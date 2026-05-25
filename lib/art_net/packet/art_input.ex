defmodule ArtNet.Packet.ArtInput do
  @moduledoc """
  Enables or disables DMX inputs on a node.

  The packet reports the target bind index and four input control bytes.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")

    field(:bind_index, {:integer, 8},
      default: 1,
      description: "Bind index of the node being configured."
    )

    field(:num_ports, {:integer, 16},
      description: "Number of input ports described by this packet."
    )

    field(:input, [{:integer, 8}],
      length: 4,
      description: "Input enable state bytes for each port."
    )
  end
end
