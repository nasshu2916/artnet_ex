defmodule ArtNet.Packet.EnumTable.PortAddress do
  @moduledoc """
  Port-Address authority values used by `ArtNet.Packet.BitField.Status1`.

    * `:unknown` - authority is unknown.
    * `:front` - address is set by front-panel controls.
    * `:net` - address is set by network programming.
    * `:unused` - reserved value.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 2],
    unknown: 0b00,
    front: 0b01,
    net: 0b10,
    unused: 0b11
  )
end
