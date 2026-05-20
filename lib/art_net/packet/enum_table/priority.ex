defmodule ArtNet.Packet.EnumTable.Priority do
  @moduledoc """
  Diagnostic priority values used by `ArtNet.Packet.ArtPoll` and
  `ArtNet.Packet.ArtDiagData`.

    * `:dp_all` - all diagnostic messages.
    * `:dp_low` - low priority and above.
    * `:dp_med` - medium priority and above.
    * `:dp_high` - high priority and above.
    * `:dp_critical` - critical messages only.
    * `:dp_volatile` - volatile messages.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    dp_all: 0x00,
    dp_low: 0x10,
    dp_med: 0x40,
    dp_high: 0x80,
    dp_critical: 0xE0,
    dp_volatile: 0xF0
  )
end
