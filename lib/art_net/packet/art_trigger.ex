defmodule ArtNet.Packet.ArtTrigger do
  @moduledoc """
  Sends trigger macro commands.

  This packet carries OEM-specific trigger information identified by `key`,
  `subkey`, and payload bytes.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: {:op_trigger, 0x9900} do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:oem, {:integer, 16}, description: "OEM code defining the trigger data format.")
    field(:key, {:integer, 8}, description: "Trigger key value.")
    field(:sub_key, {:integer, 8}, description: "Trigger sub-key value.")

    field(:data, [{:integer, 8}],
      length: 512,
      description: "OEM-specific trigger data bytes."
    )
  end
end
