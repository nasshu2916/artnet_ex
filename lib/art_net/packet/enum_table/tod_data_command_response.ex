defmodule ArtNet.Packet.EnumTable.TodDataCommandResponse do
  @moduledoc """
  TOD data command response values used by `ArtNet.Packet.ArtTodData`.

    * `:tod_full` - packet contains a full Table of Devices response.
    * `:tod_nak` - request was rejected.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    tod_full: 0x00,
    tod_nak: 0xFF
  )
end
