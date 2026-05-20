defmodule ArtNet.Packet.ArtInput do
  @moduledoc """
  Enables or disables DMX inputs on a node.

  The packet reports the target bind index and four input control bytes.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:bind_index, {:integer, 8}, default: 1)
    field(:num_ports, {:integer, 16})
    field(:input, [{:integer, 8}], length: 4)
  end
end
