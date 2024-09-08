defmodule ArtNet.Packet.BitField.PortType do
  use ArtNet.Packet.BitField

  alias ArtNet.Packet.EnumTable

  defbitfield size: 8 do
    field(:port_type, {:enum_table, EnumTable.PortType})
    field(:input, :boolean)
    field(:output, :boolean)
  end
end
