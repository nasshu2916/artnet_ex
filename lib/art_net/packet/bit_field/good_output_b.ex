defmodule ArtNet.Packet.BitField.GoodOutputB do
  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:background_discovery_disabled, :boolean, offset: 4, default: false)
    field(:discovery_not_running, :boolean, default: false)
    field(:continuous_output_style, :boolean, default: false)
    field(:rdm_disabled, :boolean, default: false)
  end
end
