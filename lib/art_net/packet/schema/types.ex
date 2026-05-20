defmodule ArtNet.Packet.Schema.Types do
  @moduledoc false

  @type format :: ArtNet.Packet.Schema.format()

  @type bit_field_format :: ArtNet.Packet.Schema.bit_field_format()

  @doc false
  @spec type_for(format()) :: Macro.t()
  def type_for([format]), do: [type_for(format)]
  def type_for({:integer, _size}), do: :integer
  def type_for({:integer, _size, :little_endian}), do: :integer
  def type_for({:binary, _size}), do: :binary
  def type_for({:string, _size}), do: {{:., [], [{:__aliases__, [], [:String]}, :t]}, [], []}

  def type_for({:enum_table, enum_module}),
    do: {{:., [], [{:__aliases__, [], [enum_module]}, :type]}, [], []}

  def type_for({:bit_field, bit_field_module}),
    do: {{:., [], [{:__aliases__, [], [bit_field_module]}, :t]}, [], []}

  @doc false
  @spec bit_field_type_for(bit_field_format()) :: Macro.t()
  def bit_field_type_for(:boolean), do: :boolean

  def bit_field_type_for({:enum_table, enum_module}),
    do: {{:., [], [{:__aliases__, [], [enum_module]}, :type]}, [], []}

  @doc """
  Converts a list of atoms into a type AST.

  ## Examples
      iex> ArtNet.Packet.Schema.Types.type_ast([:key1])
      :key1

      iex> ArtNet.Packet.Schema.Types.type_ast([:key1, :key2])
      {:|, [], [:key1, :key2]}

      iex> ArtNet.Packet.Schema.Types.type_ast([:key1, :key2, :key3, :key4])
      {:|, [], [:key1, {:|, [], [:key2, {:|, [], [:key3, :key4]}]}]}
  """
  @spec type_ast([atom]) :: any
  def type_ast([key]) do
    key
  end

  def type_ast(keys) do
    [key | rest] = Enum.reverse(keys)
    parse_type_ast(rest, key)
  end

  defp parse_type_ast([key], acc) do
    {:|, [], [key, acc]}
  end

  defp parse_type_ast([key | rest], acc) do
    parse_type_ast(rest, {:|, [], [key, acc]})
  end
end
