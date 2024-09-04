defmodule ArtNet.Encoder do
  import Bitwise

  @spec encode(any, atom, Keyword.t()) :: {:ok, binary} | :error
  def encode(value, :uint8, _opts), do: integer(value, 8)
  def encode(value, :uint16, _opts), do: integer(value, 16)

  def encode(value, :binary, opts), do: binary(value, Keyword.get(opts, :size))

  @doc """
  Encodes an integer value into a binary.

  This function is used to encode integer values into a binary.

  - `value` is the integer to encode.
  - `size` is the size of the integer in bits.

  The function returns `{:ok, binary}` if the integer was successfully encoded.
  If the integer could not be encoded, the function returns `:error`.

  ## Examples
      iex> ArtNet.Encoder.integer(0x0102, 16)
      {:ok, <<1, 2>>}

      iex> ArtNet.Encoder.integer(0x01020304, 32)
      {:ok, <<1, 2, 3, 4>>}

      iex> ArtNet.Encoder.integer(0x0102, 8)
      :error
  """
  @spec integer(non_neg_integer, pos_integer) :: {:ok, binary} | :error
  def integer(value, size) when 0 <= value and value < 1 <<< size do
    {:ok, <<value::size(size)>>}
  end

  def integer(_, _) do
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
  def binary(value, nil) do
    {:ok, value}
  end

  def binary(value, size) do
    value_size = byte_size(value)

    cond do
      value_size == size -> {:ok, value}
      value_size < size -> {:ok, value <> <<0::size((size - value_size) * 8)>>}
      true -> :error
    end
  end
end
