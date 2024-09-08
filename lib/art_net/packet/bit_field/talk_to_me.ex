defmodule ArtNet.Packet.BitField.TalkToMe do
  use ArtNet.Packet.BitField

  defbitfield size: 8 do
    field(:reply_on_change, :boolean, offset: 1)
    field(:diagnostics, :boolean)
    field(:diag_unicast, :boolean)
    field(:vlc, :boolean)
  end
end
