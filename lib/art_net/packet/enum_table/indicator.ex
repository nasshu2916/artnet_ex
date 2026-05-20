defmodule ArtNet.Packet.EnumTable.Indicator do
  @moduledoc """
  Indicator state values used by `ArtNet.Packet.BitField.Status1`.

    * `:unknown` - indicator state is unknown.
    * `:locate` - locate indication is active.
    * `:mute` - indicators are muted.
    * `:normal` - indicators are in normal mode.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 2],
    unknown: 0b00,
    locate: 0b01,
    mute: 0b10,
    normal: 0b11
  )
end
