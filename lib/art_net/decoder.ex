defmodule ArtNet.Decoder do
  @spec parse(binary, format :: atom, size :: integer | nil) :: {:ok, {any, binary}} | :error
  def parse(_, type, nil) when type in [:integer, :little_integer] do
    :error
  end

  def parse(data, :integer, size) do
    case data do
      <<value::size(size), rest::binary>> ->
        {:ok, {value, rest}}

      _ ->
        :error
    end
  end

  def parse(data, :little_integer, size) do
    case data do
      <<value::little-size(size), rest::binary>> ->
        {:ok, {value, rest}}

      _ ->
        :error
    end
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
end
