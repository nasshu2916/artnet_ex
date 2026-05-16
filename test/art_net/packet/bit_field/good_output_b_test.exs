defmodule ArtNet.Packet.BitField.GoodOutputBTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.BitField.GoodOutputB

  test "decode/encode" do
    bit_field = %GoodOutputB{
      background_discovery_disabled: true,
      discovery_not_running: false,
      continuous_output_style: true,
      rdm_disabled: true
    }

    assert GoodOutputB.encode(bit_field) == {:ok, 0b11010000}
    assert GoodOutputB.decode(0b11010000) == {:ok, bit_field}
  end
end
