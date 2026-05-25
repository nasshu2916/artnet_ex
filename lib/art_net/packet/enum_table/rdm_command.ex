defmodule ArtNet.Packet.EnumTable.RdmCommand do
  @moduledoc """
  ArtRdm command values used by `ArtNet.Packet.ArtRdm`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    ar_process: {0x00, description: "Process the embedded RDM data."}
  )
end
