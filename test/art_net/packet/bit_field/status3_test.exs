defmodule ArtNet.Packet.BitField.Status3Test do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.BitField.Status3

  test "decode/encode" do
    bit_field = %Status3{
      background_discovery_control: true,
      background_queue: true,
      rdmnet: false,
      port_direction_switch: true,
      llrp: false,
      programmable_failsafe: true,
      failsafe_state: :all_full
    }

    assert Status3.encode(bit_field) == {:ok, 0b10101011}
    assert Status3.decode(0b10101011) == {:ok, bit_field}
  end
end
