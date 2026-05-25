defmodule ArtNet.Packet.EnumTable.PortType do
  @moduledoc """
  Port protocol type values used by `ArtNet.Packet.BitField.PortType`.
  """

  use ArtNet.Packet.EnumTable

  defenumtable([bit_size: 6],
    dmx512: {0b0000, description: "DMX512."},
    midi: {0b0001, description: "MIDI."},
    avab: {0b0010, description: "Avab."},
    colortran: {0b0011, description: "Colortran CMX."},
    adb: {0b0100, description: "ADB 62.5."},
    art_net: {0b0101, description: "Art-Net."},
    dali: {0b0110, description: "DALI."}
  )
end
