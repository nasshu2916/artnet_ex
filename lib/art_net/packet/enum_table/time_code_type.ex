defmodule ArtNet.Packet.EnumTable.TimeCodeType do
  @moduledoc """
  Time code type values used by `ArtNet.Packet.ArtTimeCode`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    film: {0x00, description: "24 fps film time code."},
    ebu: {0x01, description: "25 fps EBU time code."},
    drop_frame: {0x02, description: "29.97 fps drop-frame time code."},
    smpte: {0x03, description: "30 fps SMPTE time code."}
  )
end
