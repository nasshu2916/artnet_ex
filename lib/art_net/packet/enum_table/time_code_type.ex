defmodule ArtNet.Packet.EnumTable.TimeCodeType do
  @moduledoc """
  Time code type values used by `ArtNet.Packet.ArtTimeCode`.

    * `:film` - 24 fps film time code.
    * `:ebu` - 25 fps EBU time code.
    * `:drop_frame` - 29.97 fps drop-frame time code.
    * `:smpte` - 30 fps SMPTE time code.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    film: 0x00,
    ebu: 0x01,
    drop_frame: 0x02,
    smpte: 0x03
  )
end
