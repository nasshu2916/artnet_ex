defmodule ArtNet.Packet.EnumTable do
  defmacro __using__(_) do
    quote do
      import ArtNet.Packet.EnumTable, only: [defenumtable: 2]

      @before_compile ArtNet.Packet.EnumTable
    end
  end

  defmacro defenumtable(opts, table) do
    quote bind_quoted: [opts: opts, table: table] do
      keys = Enum.map(table, fn {key, _value} -> key end)
      bit_size = Keyword.fetch!(opts, :bit_size)

      @type type :: unquote(ArtNet.Misc.type_ast(keys))

      Module.put_attribute(__MODULE__, :bit_size, bit_size)
      Module.put_attribute(__MODULE__, :enum_table, table)

      def bit_size, do: @bit_size

      for {key, value} <- table do
        def unquote(key)(), do: unquote(value)
      end

      for {key, value} <- table do
        def to_code(unquote(key)), do: {:ok, unquote(value)}
      end

      for {key, value} <- table do
        def to_atom(unquote(value)), do: {:ok, unquote(key)}
      end

      def to_code(_), do: :error
      def to_atom(_), do: :error
    end
  end

  defmacro __before_compile__(env) do
    bit_size = Module.get_attribute(env.module, :bit_size)
    enum_table = Module.get_attribute(env.module, :enum_table)

    validate_enum_values!(env.module, bit_size, enum_table)

    quote do
    end
  end

  defp validate_enum_values!(module, bit_size, enum_table) do
    max_value = Bitwise.bsl(1, bit_size) - 1

    Enum.each(enum_table, fn {key, value} ->
      unless valid_enum_value?(value, max_value) do
        raise ArgumentError,
              "#{inspect(module)}.#{key} value #{format_value(value, bit_size)} does not fit in bit_size #{bit_size}; expected #{format_value(0, bit_size)}..#{format_value(max_value, bit_size)}"
      end
    end)
  end

  defp valid_enum_value?(value, max_value) when is_integer(value), do: value in 0..max_value
  defp valid_enum_value?(_value, _max_value), do: false

  defp format_value(value, bit_size) when is_integer(value) do
    binary =
      value
      |> Integer.to_string(2)
      |> String.pad_leading(bit_size, "0")

    "#{value} (0b#{binary})"
  end

  defp format_value(value, _bit_size), do: inspect(value)
end
