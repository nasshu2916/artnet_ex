defmodule ArtNet.Packet.ArtTrigger do
  @moduledoc """
  Sends trigger macro commands.

  This packet carries OEM-specific trigger information identified by `key`,
  `subkey`, and payload bytes.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:oem, {:integer, 16})
    field(:key, {:integer, 8})
    field(:sub_key, {:integer, 8})
    field(:data, [{:integer, 8}], length: 512)
  end
end
