defmodule ArtNet.Packet.EnumTable.Priority do
  @moduledoc """
  Diagnostic priority values used by `ArtNet.Packet.ArtPoll` and
  `ArtNet.Packet.ArtDiagData`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    dp_all: {0x00, description: "All diagnostic messages."},
    dp_low: {0x10, description: "Low priority and above."},
    dp_med: {0x40, description: "Medium priority and above."},
    dp_high: {0x80, description: "High priority and above."},
    dp_critical: {0xE0, description: "Critical messages only."},
    dp_volatile: {0xF0, description: "Volatile messages."}
  )
end
