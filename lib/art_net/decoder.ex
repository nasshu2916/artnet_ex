defmodule ArtNet.Decoder do
  @spec decode(binary, format :: atom, Keyword.t()) :: {:ok, {any, binary}} | :error
  def decode(data, :uint8, opts) do
    byte_order = Keyword.get(opts, :byte_order, :big)
    integer(data, 8, byte_order)
  end

  def decode(data, :uint16, opts) do
    byte_order = Keyword.get(opts, :byte_order, :big)
    integer(data, 16, byte_order)
  end

  def decode(data, :binary, opt) do
    size = Keyword.get(opt, :size)
    binary(data, size)
  end

  @doc """
  Extracts an integer value from a binary.

  This function is used to extract integer values from a binary.

  - `data` is the binary to extract the integer from.
  - `size` is the size of the integer in bits.
  - `byte_order` is the byte order of the integer.

  The function returns `{:ok, {value, rest}}` if the integer was successfully extracted.
  The `value` is the extracted integer and `rest` is the remaining binary.

  If the integer could not be extracted, the function returns `:error`.

  ## Examples
      iex> ArtNet.Decoder.integer(<<1, 2, 3, 4>>, 16, :big)
      {:ok, {0x0102, <<3, 4>>}}

      iex> ArtNet.Decoder.integer(<<1, 2, 3, 4>>, 16, :little)
      {:ok, {0x0201, <<3, 4>>}}

      iex> ArtNet.Decoder.integer(<<1, 2, 3, 4>>, 32, :big)
      {:ok, {0x01020304, <<>>}}

      iex> ArtNet.Decoder.integer(<<1, 2, 3, 4>>, 32, :little)
      {:ok, {0x04030201, <<>>}}

      iex> ArtNet.Decoder.integer(<<1, 2, 3, 4>>, 5, :big)
      :error

      iex> ArtNet.Decoder.integer(<<1, 2, 3>>, 32, :big)
      :error
  """
  @spec integer(binary, pos_integer, :big | :little) :: {:ok, {non_neg_integer, binary}} | :error
  def integer(data, size, :big) do
    big_integer(data, size)
  end

  def integer(data, size, :little) do
    little_integer(data, size)
  end

  defp big_integer(data, size) do
    case data do
      <<value::size(size), rest::binary>> -> {:ok, {value, rest}}
      _ -> :error
    end
  end

  defp little_integer(data, size) do
    case data do
      <<value::little-size(size), rest::binary>> -> {:ok, {value, rest}}
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
