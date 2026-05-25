defmodule ArtNet.Packet.EnumTable.Indicator do
  @moduledoc """
  Indicator state values used by `ArtNet.Packet.BitField.Status1`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 2],
    unknown: {0b00, description: "Indicator state is unknown."},
    locate: {0b01, description: "Locate indication is active."},
    mute: {0b10, description: "Indicators are muted."},
    normal: {0b11, description: "Indicators are in normal mode."}
  )
end
