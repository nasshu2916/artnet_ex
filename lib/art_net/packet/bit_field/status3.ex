defmodule ArtNet.Packet.BitField.Status3 do
  @moduledoc """
  Status3 bit field used by `ArtNet.Packet.ArtPollReply`.

  This field reports newer discovery, RDMnet, LLRP, and failsafe capabilities.

    * `:background_discovery_control` - background discovery can be controlled.
    * `:background_queue` - background discovery queue is supported.
    * `:rdmnet` - RDMnet is supported.
    * `:port_direction_switch` - port direction can be switched.
    * `:llrp` - LLRP is supported.
    * `:programmable_failsafe` - failsafe behavior can be programmed.
    * `:failsafe_state` - active failsafe state reported by
      `ArtNet.Packet.EnumTable.FailsafeState`.
  """

  use ArtNet.Packet.BitField

  alias ArtNet.Packet.EnumTable

  defbitfield bit_size: 8 do
    field(:background_discovery_control, :boolean, default: false)
    field(:background_queue, :boolean, default: false)
    field(:rdmnet, :boolean, default: false)
    field(:port_direction_switch, :boolean, default: false)
    field(:llrp, :boolean, default: false)
    field(:programmable_failsafe, :boolean, default: false)
    field(:failsafe_state, {:enum_table, EnumTable.FailsafeState}, default: :hold_last)
  end
end
