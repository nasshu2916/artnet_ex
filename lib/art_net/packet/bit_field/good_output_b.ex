defmodule ArtNet.Packet.BitField.GoodOutputB do
  @moduledoc """
  GoodOutputB bit field used by `ArtNet.Packet.ArtPollReply`.

  The packet contains one `GoodOutputB` value for each of the four reported
  ports. These bits extend the output status reported by `GoodOutput`.

    * `:background_discovery_disabled` - RDM background discovery is disabled.
    * `:discovery_not_running` - background discovery is not currently running.
    * `:continuous_output_style` - port uses continuous output style.
    * `:rdm_disabled` - RDM is disabled on the output.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:background_discovery_disabled, :boolean, offset: 4, default: false)
    field(:discovery_not_running, :boolean, default: false)
    field(:continuous_output_style, :boolean, default: false)
    field(:rdm_disabled, :boolean, default: false)
  end
end
