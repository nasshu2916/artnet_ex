defmodule ArtNet.Packet.BitField.Status3 do
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
