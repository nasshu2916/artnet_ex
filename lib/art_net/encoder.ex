defmodule ArtNet.Encoder do
  import Bitwise

  def encode(value, :uint8, opts) do
    integer(value, 8, Keyword.get(opts, :byte_order, :big))
  end

  def encode(value, :uint16, opts) do
    integer(value, 16, Keyword.get(opts, :byte_order, :big))
  end

  def encode(value, :binary, opts) do
    binary(value, Keyword.get(opts, :size))
  end

  def encode(_, _, _) do
    :error
  end

  @doc """
  Encodes an integer value into a binary.

  This function is used to encode integer values into a binary.

  - `value` is the integer to encode.
  - `size` is the size of the integer in bits.
  - `byte_order` is the byte order of the integer.

  The function returns `{:ok, binary}` if the integer was successfully encoded.
  If the integer could not be encoded, the function returns `:error`.

  ## Examples
      iex> ArtNet.Encoder.integer(0x0102, 16, :big)
      {:ok, <<1, 2>>}

      iex> ArtNet.Encoder.integer(0x0201, 16, :little)
      {:ok, <<1, 2>>}

      iex> ArtNet.Encoder.integer(0x01020304, 32, :big)
      {:ok, <<1, 2, 3, 4>>}

      iex> ArtNet.Encoder.integer(0x04030201, 32, :little)
      {:ok, <<1, 2, 3, 4>>}

      iex> ArtNet.Encoder.integer(0x0102, 8, :big)
      :error
  """
  @spec integer(non_neg_integer, pos_integer, :big | :little) :: {:ok, binary} | :error
  def integer(value, size, :big) when 0 <= value and value < 1 <<< size do
    {:ok, <<value::size(size)>>}
  end

  def integer(value, size, :little) when 0 <= value and value < 1 <<< size do
    {:ok, <<value::little-size(size)>>}
  end

  def integer(_, _, _) do
    :error
  end

  @doc """
  Encodes a binary value into a binary.

  This function is used to encode binary values into a binary.

  - `data` is the binary to encode.
  - `size` is the size of the binary in bytes. If the binary is smaller than
    the size, it is padded with zeros.

  The function returns `{:ok, binary}` if the binary was successfully encoded.
  If the binary could not be encoded, the function returns `:error`.

  ## Examples
      iex> ArtNet.Encoder.binary(<<1, 2>>, 2)
      {:ok, <<1, 2>>}

      iex> ArtNet.Encoder.binary(<<1>>, 4)
      {:ok, <<1, 0, 0, 0>>}

      iex> ArtNet.Encoder.binary(<<1, 2>>, 1)
      :error
  """
  @spec binary(binary, pos_integer) :: {:ok, binary} | :error
  def binary(data, nil) do
    {:ok, data}
  end

  def binary(data, size) do
    data_size = byte_size(data)

    cond do
      data_size == size -> {:ok, data}
      data_size < size -> {:ok, data <> <<0::size((size - data_size) * 8)>>}
      true -> :error
    end
  end
end
