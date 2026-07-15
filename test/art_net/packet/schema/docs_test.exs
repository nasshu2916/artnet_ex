defmodule ArtNet.Packet.Schema.DocsTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.Schema
  alias ArtNet.Packet.Schema.Docs

  @schema [
    uint8: {{:integer, 8}, [description: "required|value\nnext"]},
    uint1: {{:integer, 1}, []},
    uint12: {{:integer, 12}, []},
    little16: {{:integer, 16, :little_endian}, []},
    little12: {{:integer, 12, :little_endian}, []},
    binary_rest: {{:binary, nil}, []},
    binary2: {{:binary, 2}, []},
    string_rest: {{:string, nil}, []},
    string3: {{:string, 3}, []},
    priority: {{:enum_table, ArtNet.Packet.EnumTable.Priority}, []},
    port_type: {{:enum_table, ArtNet.Packet.EnumTable.PortType}, []},
    flags: {{:bit_field, ArtNet.Packet.BitField.TalkToMe}, []},
    variable_list: {[{:integer, 8}], []},
    byte_list: {[{:integer, 16}], [length: 2]},
    bit_list: {[{:integer, 12}], [length: 2]},
    binary_list: {[{:binary, nil}], [length: 2]},
    nested_list: {[[{:integer, 8}]], []}
  ]
  @fields Enum.map(@schema, fn {name, _} -> {name, nil} end)

  describe "module documentation" do
    test "normalizes and joins documentation" do
      assert Docs.moduledoc_text(false) == false
      assert Docs.moduledoc_text(nil) == ""
      assert Docs.moduledoc_text({10, "Module docs"}) == "Module docs"
      assert Docs.moduledoc_text("Module docs") == "Module docs"
      assert Docs.append_section("Module docs\n", "Section\n") == "Module docs\n\nSection"
      assert Docs.append_section("", "Section") == "Section"
    end

    test "builds schema module and function documentation" do
      assert Schema.__schema_doc__() =~ "schema in declaration order"
      assert Schema.__op_code_doc__(0x5000) =~ "`0x5000`"
      assert Schema.__moduledoc_with_layout__(false, nil, [], [], [], true) == false

      assert Schema.__moduledoc_with_layout__(
               {1, "Packet docs"},
               ArtNet.Packet.ArtDmx,
               [],
               [],
               [],
               false
             ) =~ "Packet docs\n\n## Packet layout"
    end
  end

  describe "packet_layout_table/5" do
    setup do
      table = Docs.packet_layout_table(ArtNet.Packet.ArtDmx, @schema, @fields, [:uint8], true)
      %{table: table}
    end

    test "renders descriptions, defaults, and scalar formats", %{table: table} do
      assert table =~ "required\\|value<br>next"
      assert table =~ "| required | 1 byte | unsigned integer (8 bits) |"
      assert table =~ "| `nil` | 1 bit | unsigned integer (1 bits) |"
      assert table =~ "| `nil` | 12 bits | unsigned integer (12 bits) |"
      assert table =~ "2 bytes | little-endian unsigned integer (16 bits)"
      assert table =~ "variable | binary"
      assert table =~ "3 bytes | null-padded string (3 bytes)"
      assert table =~ "`ArtNet.Packet.EnumTable.Priority` enum"
      assert table =~ "`ArtNet.Packet.BitField.TalkToMe` bit field"
    end

    test "renders fixed, variable, and nested list formats", %{table: table} do
      assert table =~ "variable (1 byte each)"
      assert table =~ "4 bytes (2 bytes each)"
      assert table =~ "24 bits (12 bits each)"
      assert table =~ "2 values (variable each)"

      assert table =~
               "variable (variable (1 byte each) each) | list of list of unsigned integer (8 bits)"
    end

    test "omits the protocol version header when it is not required" do
      refute Docs.packet_layout_table(ArtNet.Packet.ArtDmx, [], [], [], false) =~ "`prot_ver`"
    end
  end

  describe "enum and bit-field tables" do
    test "renders enum values" do
      table = Docs.enum_values_table([ready: 1, unknown: :other], [], 2)

      assert table =~ "`0x1 / 0b01`"
      assert table =~ "`:other`"
    end

    test "renders bit-field layouts" do
      table =
        Docs.bit_field_layout_table(
          [
            enabled: {:boolean, {0, 1}},
            state: {{:enum_table, ArtNet.Packet.EnumTable.FailsafeState}, {1, 2}}
          ],
          [enabled: false, state: :hold_last],
          [:enabled],
          enabled: "Enabled",
          state: "State"
        )

      assert table =~ "| `enabled` | Enabled | `0` | required | `boolean` flag |"
      assert table =~ "| `state` | State | `1..2` | `:hold_last` |"
      assert table =~ "enum (`2` bits)"
    end
  end
end
