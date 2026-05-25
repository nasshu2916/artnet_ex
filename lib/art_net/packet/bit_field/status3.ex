defmodule ArtNet.Packet.BitField.Status3 do
  @moduledoc """
  Status3 bit field used by `ArtNet.Packet.ArtPollReply`.

  This field reports newer discovery, RDMnet, LLRP, and failsafe capabilities.
  """

  use ArtNet.Packet.BitField

  alias ArtNet.Packet.EnumTable

  defbitfield bit_size: 8 do
    field(:background_discovery_control, :boolean,
      default: false,
      description: "Background discovery can be controlled."
    )

    field(:background_queue, :boolean,
      default: false,
      description: "Background discovery queue is supported."
    )

    field(:rdmnet, :boolean, default: false, description: "RDMnet is supported.")

    field(:port_direction_switch, :boolean,
      default: false,
      description: "Port direction can be switched."
    )

    field(:llrp, :boolean, default: false, description: "LLRP is supported.")

    field(:programmable_failsafe, :boolean,
      default: false,
      description: "Failsafe behavior can be programmed."
    )

    field(:failsafe_state, {:enum_table, EnumTable.FailsafeState},
      default: :hold_last,
      description: "Active failsafe state reported by `ArtNet.Packet.EnumTable.FailsafeState`."
    )
  end
end
