defmodule ArtNet.Packet.BitField.TalkToMe do
  @moduledoc """
  TalkToMe bit field used by `ArtNet.Packet.ArtPoll`.

  This field tells nodes how the controller wants `ArtPollReply` responses and
  diagnostics to be sent.

    * `:reply_on_change` - send replies when node conditions change.
    * `:diagnostics` - send diagnostics messages.
    * `:diag_unicast` - send diagnostics by unicast.
    * `:vlc` - include VLC transmission support in discovery.
    * `:targeted_mode` - use targeted mode fields in `ArtPoll`.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:reply_on_change, :boolean, offset: 1)
    field(:diagnostics, :boolean)
    field(:diag_unicast, :boolean)
    field(:vlc, :boolean)
    field(:targeted_mode, :boolean, default: false)
  end
end
