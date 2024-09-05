defmodule ArtNet.Misc do
  @doc """
  Converts a list of atoms into a type AST.

  ## Examples
      iex> ArtNet.Misc.type_ast([:key1])
      :key1

      iex> ArtNet.Misc.type_ast([:key1, :key2])
      {:|, [], [:key1, :key2]}

      iex> ArtNet.Misc.type_ast([:key1, :key2, :key3, :key4])
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
