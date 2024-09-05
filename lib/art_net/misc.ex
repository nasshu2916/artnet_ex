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
  def type_ast([key]), do: key
  def type_ast(keys), do: parse_type_ast(keys)

  defp parse_type_ast([left, right]) do
    {:|, [], [left, right]}
  end

  defp parse_type_ast([left | rest]) do
    {:|, [], [left, parse_type_ast(rest)]}
  end
end
