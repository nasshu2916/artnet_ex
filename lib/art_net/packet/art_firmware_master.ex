defmodule ArtNet.Packet.ArtFirmwareMaster do
  @moduledoc """
  Uploads firmware or firmware extensions to a node.

  The packet identifies the firmware block type and carries one transfer block
  of firmware data.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:type, {:enum_table, EnumTable.FirmwareMasterType})
    field(:block_id, {:integer, 8})
    field(:firmware_length, {:integer, 32})
    field(:spare, {:binary, 20}, default: <<0::size(160)>>)
    field(:data, [{:integer, 16}], length: 512)
  end
end
