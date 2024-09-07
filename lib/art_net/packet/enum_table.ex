defmodule ArtNet.Packet.EnumTable do
  defmacro __using__(_) do
    quote do
      import ArtNet.Packet.EnumTable, only: [defenumtable: 2]
    end
  end

  defmacro defenumtable(opts, table) do
    quote bind_quoted: [opts: opts, table: table] do
      keys = Enum.map(table, fn {key, _value} -> key end)
      bit_size = Keyword.fetch!(opts, :bit_size)

      @type keys :: unquote(ArtNet.Misc.type_ast(keys))

      Module.put_attribute(__MODULE__, :keys, keys)
      Module.put_attribute(__MODULE__, :bit_size, bit_size)

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
end
