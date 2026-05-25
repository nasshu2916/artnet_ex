defmodule ArtNet.Packet.EnumTable.TodDataCommandResponse do
  @moduledoc """
  TOD data command response values used by `ArtNet.Packet.ArtTodData`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    tod_full: {0x00, description: "Packet contains a full Table of Devices response."},
    tod_nak: {0xFF, description: "Request was rejected."}
  )
end
