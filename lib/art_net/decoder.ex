defmodule ArtNet.Decoder do
  @spec decode(binary, format :: atom | [atom], Keyword.t()) :: {:ok, {any, binary}} | :error
  def decode(data, [format], opts), do: decode_list(data, format, opts)

  def decode(data, :uint8, _opts), do: integer(data, 8)
  def decode(data, :uint16, _opts), do: integer(data, 16)

  def decode(data, :binary, opt), do: binary(data, Keyword.get(opt, :size))

  @doc """
  Decodes a list of values from a binary.

  This function is used to decode a list of values from a binary.

  - `data` is the binary to decode the values from.
  - `format` is the format of the values.
  - `opts` is a keyword of format options.

  The function returns `{:ok, {list, binary}}` if the values were successfully decoded.
  The `list` is the decoded list of values and `binary` is the remaining binary.

  If the values could not be decoded, the function returns `:error`.

  ## Examples
      iex> ArtNet.Decoder.decode_list(<<1, 2, 3>>, :uint8, [])
      {:ok, {[1, 2, 3], <<>>}}

      iex> ArtNet.Decoder.decode_list(<<1, 2, 3>>, :uint16, [])
      :error

      iex> ArtNet.Decoder.decode_list(<<0, 1, 1, 1>>, :uint16, [])
      {:ok, {[1, 0x0101], <<>>}}
  """
  @spec decode_list(binary, atom, Keyword.t()) :: {:ok, {list, binary}} | :error
  def decode_list(data, format, opts) do
    case do_decode_list(data, [], format, opts) do
      :error -> :error
      {:ok, decoded_list} -> {:ok, {decoded_list, <<>>}}
    end
  end

  def do_decode_list(<<>>, acc, _, _), do: {:ok, Enum.reverse(acc)}

  def do_decode_list(data, acc, format, opts) do
    case decode(data, format, opts) do
      {:ok, {decoded, rest}} -> do_decode_list(rest, [decoded | acc], format, opts)
      :error -> :error
    end
  end

  @doc """
  Extracts an integer value from a binary.

  This function is used to extract integer values from a binary.

  - `data` is the binary to extract the integer from.
  - `size` is the size of the integer in bits.

  The function returns `{:ok, {value, rest}}` if the integer was successfully extracted.
  The `value` is the extracted integer and `rest` is the remaining binary.

  If the integer could not be extracted, the function returns `:error`.

  ## Examples
      iex> ArtNet.Decoder.integer(<<1, 2, 3, 4>>, 16)
      {:ok, {0x0102, <<3, 4>>}}

      iex> ArtNet.Decoder.integer(<<1, 2, 3, 4>>, 32)
      {:ok, {0x01020304, <<>>}}

      iex> ArtNet.Decoder.integer(<<1, 2, 3, 4>>, 5)
      :error

      iex> ArtNet.Decoder.integer(<<1, 2, 3>>, 32)
      :error
  """
  @spec integer(binary, pos_integer) :: {:ok, {non_neg_integer, binary}} | :error
  def integer(data, size) do
    case data do
      <<value::size(size), rest::binary>> -> {:ok, {value, rest}}
      _ -> :error
    end
  end

  @doc """
  Extracts a binary value from a binary.

  This function is used to extract binary values from a binary.

  - `data` is the binary to extract the binary from.
  - `size` is the size of the binary in bytes. If `nil`, the entire binary is extracted.

  The function returns `{:ok, {value, rest}}` if the binary was successfully extracted.
  The `value` is the extracted binary and `rest` is the remaining binary.

  ## Examples
      iex> ArtNet.Decoder.binary(<<1, 2, 3, 4>>, nil)
      {:ok, {<<1, 2, 3, 4>>, <<>>}}

      iex> ArtNet.Decoder.binary(<<1, 2, 3, 4>>, 2)
      {:ok, {<<1, 2>>, <<3, 4>>}}

      iex> ArtNet.Decoder.binary(<<1, 2, 3, 4>>, 5)
      :error
  """
  @spec binary(binary, pos_integer | nil) :: {:ok, {binary, binary}} | :error
  def binary(data, nil) do
    {:ok, {data, <<>>}}
  end

  def binary(data, size) do
    case data do
      <<value::binary-size(size), rest::binary>> -> {:ok, {value, rest}}
      _ -> :error
    end
  end
end
