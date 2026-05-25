defmodule ArtNet.Packet.ArtFirmwareMaster do
  @moduledoc """
  Uploads firmware or firmware extensions to a node.

  The packet identifies the firmware block type and carries one transfer block
  of firmware data.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")

    field(:type, {:enum_table, EnumTable.FirmwareMasterType},
      description: "Firmware transfer command type."
    )

    field(:block_id, {:integer, 8}, description: "Sequential firmware block identifier.")
    field(:firmware_length, {:integer, 32}, description: "Total firmware image length in bytes.")

    field(:spare, {:binary, 20},
      default: <<0::size(160)>>,
      description: "Reserved bytes, transmitted as zero."
    )

    field(:data, [{:integer, 16}],
      length: 512,
      description: "Firmware data block words."
    )
  end
end
