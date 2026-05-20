defmodule ArtNet.Packet.BitField.Status1 do
  @moduledoc """
  Status1 bit field used by `ArtNet.Packet.ArtPollReply`.

  This field reports node capabilities and indicator state.

    * `:ubea` - UBEA is present.
    * `:rdm` - node supports RDM.
    * `:boot_rom` - node is booted from ROM.
    * `:port_address` - Port-Address authority reported by
      `ArtNet.Packet.EnumTable.PortAddress`.
    * `:indicator` - indicator state reported by
      `ArtNet.Packet.EnumTable.Indicator`.
  """

  use ArtNet.Packet.BitField

  alias ArtNet.Packet.EnumTable

  defbitfield bit_size: 8 do
    field(:ubea, :boolean)
    field(:rdm, :boolean)
    field(:boot_rom, :boolean)
    field(:port_address, {:enum_table, EnumTable.PortAddress}, offset: 1)
    field(:indicator, {:enum_table, EnumTable.Indicator})
  end
end
