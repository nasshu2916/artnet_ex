defmodule ArtNet.Packet.EnumTable.PortType do
  @moduledoc """
  Port protocol type values used by `ArtNet.Packet.BitField.PortType`.

    * `:dmx512` - DMX512.
    * `:midi` - MIDI.
    * `:avab` - Avab.
    * `:colortran` - Colortran CMX.
    * `:adb` - ADB 62.5.
    * `:art_net` - Art-Net.
    * `:dali` - DALI.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 6],
    dmx512: 0b0000,
    midi: 0b0001,
    avab: 0b0010,
    colortran: 0b0011,
    adb: 0b0100,
    art_net: 0b0101,
    dali: 0b0110
  )
end
