defmodule ArtNet.Packet.BitField.TalkToMe do
  @moduledoc """
  TalkToMe bit field used by `ArtNet.Packet.ArtPoll`.

  This field tells nodes how the controller wants `ArtPollReply` responses and
  diagnostics to be sent.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:reply_on_change, :boolean,
      offset: 1,
      description: "Send replies when node conditions change."
    )

    field(:diagnostics, :boolean, description: "Send diagnostics messages.")
    field(:diag_unicast, :boolean, description: "Send diagnostics by unicast.")
    field(:vlc, :boolean, description: "Include VLC transmission support in discovery.")

    field(:targeted_mode, :boolean,
      default: false,
      description: "Use targeted mode fields in `ArtPoll`."
    )
  end
end
