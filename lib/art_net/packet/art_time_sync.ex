defmodule ArtNet.Packet.ArtTimeSync do
  @moduledoc """
  Synchronizes real-time date and clock information.

  The current implementation keeps the payload opaque because the active
  Art-Net 4 specification does not define OpTimeSync payload fields.
  """

  use ArtNet.Packet.Schema

  # The current Art-Net 4 specification does not define OpTimeSync payload fields,
  # so keep any trailing bytes as an opaque payload.
  defpacket op_code: {:op_time_sync, 0x9800} do
    field(:payload, {:binary, nil},
      default: <<>>,
      description: "Optional time synchronization payload bytes."
    )
  end
end
