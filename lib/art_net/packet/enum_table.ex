defmodule ArtNet.Packet.EnumTable do
  @moduledoc """
  DSL for defining integer-backed enum tables.

  `ArtNet.Packet.EnumTable` maps atom values used by packet structs to the
  integer codes used on the wire. Packet schemas use enum table modules with
  the `{:enum_table, Module}` field format. Bit-field schemas may also use enum
  tables with the same format.

  ```elixir
  defmodule ArtNet.Packet.EnumTable.Priority do
    use ArtNet.Packet.EnumTable

    defenumtable([bit_size: 8],
      dp_all: 0x00,
      dp_low: 0x40,
      dp_med: 0x80,
      dp_high: 0xC0
    )
  end
  ```

  A generated enum table module receives:

    * `bit_size/0` - returns the declared size in bits.
    * one zero-arity function per enum key, returning that key's integer code.
    * `to_code/1` - converts an atom key to `{:ok, integer}` or `:error`.
    * `to_atom/1` - converts an integer code to `{:ok, atom}` or `:error`.
    * `@type type` - union type of the declared atom keys.

  At compile time, each integer code is checked against `:bit_size`. Values must
  be integers in `0..(2 ** bit_size - 1)`.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import ArtNet.Packet.EnumTable, only: [defenumtable: 2]

      @before_compile ArtNet.Packet.EnumTable
    end
  end

  @doc """
  Defines an enum table.

  The first argument is an option list and must include `:bit_size`. The second
  argument is a keyword list mapping atom keys to integer codes.

  ```elixir
  defenumtable([bit_size: 2],
    disabled: 0,
    input: 1,
    output: 2
  )
  ```
  """
  defmacro defenumtable(opts, table) do
    quote bind_quoted: [opts: opts, table: table] do
      keys = Enum.map(table, fn {key, _value} -> key end)
      bit_size = Keyword.fetch!(opts, :bit_size)

      @type type :: unquote(ArtNet.Packet.Schema.Types.type_ast(keys))

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
