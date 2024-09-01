defmodule ArtNet.Decoder do
  @spec decode(binary, format :: atom, Keyword.t()) :: {:ok, {any, binary}} | :error
  def decode(data, :uint8, opt) do
    do_decode_integer(data, 8, opt)
  end

  def decode(data, :uint16, opt) do
    do_decode_integer(data, 16, opt)
  end

  def decode(data, :binary, opt) do
    size = Keyword.fetch!(opt, :size)
    do_decode_binary(data, size)
  end

  @spec do_decode_integer(binary, pos_integer, Keyword.t()) ::
          {:ok, {non_neg_integer, binary}} | :error
  defp do_decode_integer(data, size, opts) do
    byte_order = Keyword.fetch!(opts, :byte_order)

    case {data, byte_order} do
      {<<value::size(size), rest::binary>>, :big} -> {:ok, {value, rest}}
      {<<value::little-size(size), rest::binary>>, :little} -> {:ok, {value, rest}}
      _ -> :error
    end
  end

  defp do_decode_binary(data, nil) do
    {:ok, {data, <<>>}}
  end

  defp do_decode_binary(data, size) do
    case data do
      <<value::binary-size(size), rest::binary>> -> {:ok, {value, rest}}
      _ -> :error
    end
  end
end
