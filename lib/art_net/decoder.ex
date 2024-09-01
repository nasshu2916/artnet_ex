defmodule ArtNet.Decoder do
  @spec parse(binary, format :: atom, size :: integer | nil) :: {:ok, {any, binary}} | :error
  def parse(data, :uint8, nil) do
    do_parse_integer(data, 8)
  end

  def parse(data, :uint16, nil) do
    do_parse_integer(data, 16)
  end

  def parse(data, :binary, nil) do
    {:ok, {data, <<>>}}
  end

  def parse(data, :binary, size) do
    case data do
      <<value::binary-size(size), rest::binary>> ->
        {:ok, {value, rest}}

      _ ->
        :error
    end
  end

  @spec do_parse_integer(binary, pos_integer) :: {:ok, {non_neg_integer, binary}} | :error
  defp do_parse_integer(data, size) do
    case data do
      <<value::size(size), rest::binary>> -> {:ok, {value, rest}}
      _ -> :error
    end
  end
end
