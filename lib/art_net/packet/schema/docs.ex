defmodule ArtNet.Packet.Schema.Docs do
  @moduledoc false

  alias ArtNet.Packet.Schema

  @type packet_schema :: [{atom, {Schema.format(), Keyword.t()}}]
  @type bit_field_schema :: [
          {atom,
           {Schema.bit_field_format(), {start_bit :: non_neg_integer, length :: pos_integer}}}
        ]

  @spec moduledoc_text(false | nil | String.t() | {non_neg_integer, String.t()}) ::
          false | String.t()
  def moduledoc_text(false), do: false
  def moduledoc_text(nil), do: ""
  def moduledoc_text({_line, text}) when is_binary(text), do: text
  def moduledoc_text(text) when is_binary(text), do: text

  @spec append_section(String.t(), String.t()) :: String.t()
  def append_section(text, section) do
    [String.trim_trailing(text), String.trim_trailing(section)]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n\n")
  end

  @spec packet_layout_table(pos_integer, packet_schema(), Keyword.t(), [atom], boolean) ::
          String.t()
  def packet_layout_table(op_code, schema, fields, enforce_keys, require_version_header?) do
    header_rows =
      [
        ["Header", "`id`", "", "fixed", "8 bytes", "`\"Art-Net\\\\0\"`"],
        [
          "Header",
          "`op_code`",
          "",
          "`#{op_code_value(op_code)}`",
          "2 bytes",
          "little-endian OpCode"
        ]
      ] ++ version_header_rows(require_version_header?)

    payload_rows =
      Enum.map(schema, fn {name, {format, opts}} ->
        [
          "Payload",
          "`#{name}`",
          description_text(opts),
          default_description(name, fields, enforce_keys),
          size_description(format, opts),
          packet_format_description(format)
        ]
      end)

    markdown_table(
      ["Part", "Field", "Description", "Default", "Size", "Format"],
      header_rows ++ payload_rows
    )
  end

  @spec enum_values_table(Keyword.t(), Keyword.t(), pos_integer) :: String.t()
  def enum_values_table(table, descriptions, bit_size) do
    rows =
      Enum.map(table, fn {atom, value} ->
        [
          "`#{atom}`",
          description_text(descriptions, atom),
          "`#{format_table_value(value, bit_size)}`"
        ]
      end)

    """
    ## Values

    #{markdown_table(["Atom", "Description", "Value"], rows)}
    """
    |> String.trim_trailing()
  end

  @spec bit_field_layout_table(bit_field_schema(), Keyword.t(), [atom], Keyword.t()) :: String.t()
  def bit_field_layout_table(schema, fields, enforce_keys, descriptions) do
    rows =
      Enum.map(schema, fn {name, {format, {offset, size}}} ->
        [
          "`#{name}`",
          description_text(descriptions, name),
          "`#{bit_range(offset, size)}`",
          default_description(name, fields, enforce_keys),
          bit_field_format_description(format)
        ]
      end)

    markdown_table(["Field", "Description", "Bits", "Default", "Value"], rows)
  end

  @spec op_code_value(pos_integer) :: String.t()
  def op_code_value(op_code), do: inspect(op_code, base: :hex)

  defp version_header_rows(true),
    do: [["Header", "`prot_ver`", "", "`14`", "2 bytes", "protocol version"]]

  defp version_header_rows(false), do: []

  defp size_description([format], opts) do
    length = Keyword.get(opts, :length)
    element_size = size_description(format, [])

    case {length, fixed_size(format)} do
      {nil, _} -> "variable"
      {length, {:bytes, bytes}} -> "#{length * bytes} bytes"
      {length, {:bits, bits}} -> "#{length * bits} bits"
      {length, :variable} -> "#{length} values"
    end
    |> then(fn size -> "#{size} (#{element_size} each)" end)
  end

  defp size_description(format, _opts) do
    case fixed_size(format) do
      {:bytes, 1} -> "1 byte"
      {:bytes, bytes} -> "#{bytes} bytes"
      {:bits, 1} -> "1 bit"
      {:bits, bits} -> "#{bits} bits"
      :variable -> "variable"
    end
  end

  defp fixed_size({:integer, bits}) when rem(bits, 8) == 0, do: {:bytes, div(bits, 8)}
  defp fixed_size({:integer, bits}), do: {:bits, bits}

  defp fixed_size({:integer, bits, :little_endian}) when rem(bits, 8) == 0,
    do: {:bytes, div(bits, 8)}

  defp fixed_size({:integer, bits, :little_endian}), do: {:bits, bits}
  defp fixed_size({:binary, nil}), do: :variable
  defp fixed_size({:binary, bytes}), do: {:bytes, bytes}
  defp fixed_size({:string, nil}), do: :variable
  defp fixed_size({:string, bytes}), do: {:bytes, bytes}
  defp fixed_size({:enum_table, enum_module}), do: bit_or_byte_size(enum_module.bit_size())

  defp fixed_size({:bit_field, bit_field_module}),
    do: bit_or_byte_size(bit_field_module.bit_size())

  defp fixed_size([_format]), do: :variable

  defp bit_or_byte_size(bits) when rem(bits, 8) == 0, do: {:bytes, div(bits, 8)}
  defp bit_or_byte_size(bits), do: {:bits, bits}

  defp packet_format_description([format]), do: "list of #{packet_format_description(format)}"
  defp packet_format_description({:integer, bits}), do: "unsigned integer (#{bits} bits)"

  defp packet_format_description({:integer, bits, :little_endian}),
    do: "little-endian unsigned integer (#{bits} bits)"

  defp packet_format_description({:binary, nil}), do: "binary"
  defp packet_format_description({:binary, bytes}), do: "binary (#{bytes} bytes)"
  defp packet_format_description({:string, nil}), do: "string"
  defp packet_format_description({:string, bytes}), do: "null-padded string (#{bytes} bytes)"
  defp packet_format_description({:enum_table, enum_module}), do: "`#{inspect(enum_module)}` enum"

  defp packet_format_description({:bit_field, bit_field_module}),
    do: "`#{inspect(bit_field_module)}` bit field"

  defp bit_range(offset, 1), do: offset
  defp bit_range(offset, size), do: "#{offset}..#{offset + size - 1}"

  defp bit_field_format_description(:boolean), do: "`boolean` flag"

  defp bit_field_format_description({:enum_table, enum_module}) do
    "`#{inspect(enum_module)}` enum (`#{enum_module.bit_size()}` bits)"
  end

  defp default_description(name, fields, enforce_keys) do
    if name in enforce_keys do
      "required"
    else
      fields
      |> Keyword.fetch!(name)
      |> inspect()
      |> then(&"`#{&1}`")
    end
  end

  defp description_text(opts) do
    opts
    |> Keyword.get(:description, "")
    |> escape_table_cell()
  end

  defp description_text(descriptions, name) do
    descriptions
    |> Keyword.get(name, "")
    |> escape_table_cell()
  end

  defp escape_table_cell(value) do
    value
    |> String.replace("\n", "<br>")
    |> String.replace("|", "\\|")
  end

  defp format_table_value(value, bit_size) when is_integer(value) do
    hex = inspect(value, base: :hex)

    binary =
      value
      |> Integer.to_string(2)
      |> String.pad_leading(bit_size, "0")

    "#{hex} / 0b#{binary}"
  end

  defp format_table_value(value, _bit_size), do: inspect(value)

  defp markdown_table(headers, rows) do
    header = "| #{Enum.join(headers, " | ")} |"
    divider = "| #{Enum.map_join(headers, " | ", fn _ -> "---" end)} |"
    body = Enum.map_join(rows, "\n", fn row -> "| #{Enum.join(row, " | ")} |" end)

    Enum.join([header, divider, body], "\n")
  end
end
