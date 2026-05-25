defmodule ArtNet.Packet.BitField.GoodOutputB do
  @moduledoc """
  GoodOutputB bit field used by `ArtNet.Packet.ArtPollReply`.

  The packet contains one `GoodOutputB` value for each of the four reported
  ports. These bits extend the output status reported by `GoodOutput`.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:background_discovery_disabled, :boolean,
      offset: 4,
      default: false,
      description: "RDM background discovery is disabled."
    )

    field(:discovery_not_running, :boolean,
      default: false,
      description: "Background discovery is not currently running."
    )

    field(:continuous_output_style, :boolean,
      default: false,
      description: "Port uses continuous output style."
    )

    field(:rdm_disabled, :boolean,
      default: false,
      description: "RDM is disabled on the output."
    )
  end
end
