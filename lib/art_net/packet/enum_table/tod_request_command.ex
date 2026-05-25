defmodule ArtNet.Packet.EnumTable.TodRequestCommand do
  @moduledoc """
  TOD request command values used by `ArtNet.Packet.ArtTodRequest`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    tod_full: {0x00, description: "Request the full Table of Devices."}
  )
end
