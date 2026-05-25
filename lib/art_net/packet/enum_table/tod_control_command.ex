defmodule ArtNet.Packet.EnumTable.TodControlCommand do
  @moduledoc """
  TOD control command values used by `ArtNet.Packet.ArtTodControl`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    atc_none: {0x00, description: "No control command."},
    atc_flush: {0x01, description: "Flush the Table of Devices."},
    atc_end: {0x02, description: "End TOD control."},
    atc_inc_on: {0x03, description: "Enable incremental discovery."},
    atc_inc_off: {0x04, description: "Disable incremental discovery."}
  )
end
