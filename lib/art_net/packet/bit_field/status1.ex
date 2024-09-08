defmodule ArtNet.Packet.BitField.Status1 do
  use ArtNet.Packet.BitField

  alias ArtNet.Packet.EnumTable

  defbitfield size: 8 do
    field(:ubea, :boolean)
    field(:rdm, :boolean)
    field(:boot_rom, :boolean)
    field(:port_address, {:enum_table, EnumTable.PortAddress}, offset: 1)
    field(:indicator, {:enum_table, EnumTable.Indicator})
  end
end
