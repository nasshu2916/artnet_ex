defmodule ArtNet.Packet.EnumTable.TodControlCommand do
  @moduledoc """
  TOD control command values used by `ArtNet.Packet.ArtTodControl`.

    * `:atc_none` - no control command.
    * `:atc_flush` - flush the Table of Devices.
    * `:atc_end` - end TOD control.
    * `:atc_inc_on` - enable incremental discovery.
    * `:atc_inc_off` - disable incremental discovery.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 8],
    atc_none: 0x00,
    atc_flush: 0x01,
    atc_end: 0x02,
    atc_inc_on: 0x03,
    atc_inc_off: 0x04
  )
end
