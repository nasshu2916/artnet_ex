defmodule ArtNet.OpCodeTest do
  use ExUnit.Case

  alias ArtNet.OpCode

  test "registers every packet schema module" do
    packet_modules = packet_modules()

    assert packet_modules != []

    for packet_module <- packet_modules do
      {name, value} = packet_module.__op_code__()

      assert OpCode.packet_module_from_value(value) == packet_module
      assert OpCode.op_code_type(value) == name
      assert OpCode.op_code(name) == value
      assert OpCode.op_code(packet_module) == value
    end
  end

  test "returns nil for unsupported values" do
    assert OpCode.packet_module_from_value(0xFFFF) == nil
    assert OpCode.op_code_type(0xFFFF) == nil
  end

  defp packet_modules do
    :art_net
    |> Application.spec(:modules)
    |> Enum.filter(&packet_schema_module?/1)
  end

  defp packet_schema_module?(module) do
    Code.ensure_loaded!(module)

    module.module_info(:attributes)
    |> Keyword.get_values(:behaviour)
    |> List.flatten()
    |> Enum.member?(ArtNet.Packet.Schema)
  end
end
