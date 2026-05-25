defmodule ArtNet.Packet.EnumTable.PortAddress do
  @moduledoc """
  Port-Address authority values used by `ArtNet.Packet.BitField.Status1`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 2],
    unknown: {0b00, description: "Authority is unknown."},
    front: {0b01, description: "Address is set by front-panel controls."},
    net: {0b10, description: "Address is set by network programming."},
    unused: {0b11, description: "Reserved value."}
  )
end
