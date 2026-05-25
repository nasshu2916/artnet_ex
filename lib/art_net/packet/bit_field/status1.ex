defmodule ArtNet.Packet.BitField.Status1 do
  @moduledoc """
  Status1 bit field used by `ArtNet.Packet.ArtPollReply`.

  This field reports node capabilities and indicator state.
  """

  use ArtNet.Packet.BitField

  alias ArtNet.Packet.EnumTable

  defbitfield bit_size: 8 do
    field(:ubea, :boolean, description: "UBEA is present.")
    field(:rdm, :boolean, description: "Node supports RDM.")
    field(:boot_rom, :boolean, description: "Node is booted from ROM.")

    field(:port_address, {:enum_table, EnumTable.PortAddress},
      offset: 1,
      description: "Port-Address authority reported by `ArtNet.Packet.EnumTable.PortAddress`."
    )

    field(:indicator, {:enum_table, EnumTable.Indicator},
      description: "Indicator state reported by `ArtNet.Packet.EnumTable.Indicator`."
    )
  end
end
