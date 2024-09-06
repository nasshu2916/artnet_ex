defmodule ArtNet.EncodeError do
  @type t :: %__MODULE__{
          reason:
            {:encode_error, %{key: atom, type: atom, value: any()}}
            | {:invalid_data, String.t()}
        }

  defexception [:reason]

  def message(%__MODULE__{} = exception) do
    case exception.reason do
      {:encode_error, reason} -> "encoding error: #{inspect(reason)}"
      {:validate_error, reason} -> "invalid data: #{reason}"
    end
  end
end

defmodule ArtNet.Encoder do
  import Bitwise

  @spec encode(any, atom | [atom], Keyword.t()) :: {:ok, binary} | :error
  def encode(values, [format], opts), do: encode_list(values, format, opts)
  def encode(value, :uint8, _opts), do: integer(value, 8)
  def encode(value, :uint16, _opts), do: integer(value, 16)

  def encode(value, :binary, opts), do: binary(value, Keyword.get(opts, :size))
  def encode(value, :string, opts), do: binary(value, Keyword.get(opts, :size))

  @doc """
  Encodes a list of values into a binary.

  This function is used to encode a list of values into a binary.

  - `values` is the list of values to encode.
  - `format` is the format of the values.
  - `opts` is a keyword of format options.

  The function returns `{:ok, binary}` if the values were successfully encoded.
  If the values could not be encoded, the function returns `:error`.

  ## Examples
      iex> ArtNet.Encoder.encode_list([1, 2, 3], :uint8, [])
      {:ok, <<1, 2, 3>>}

      iex> ArtNet.Encoder.encode_list([1, 2, 0x1111], :uint16, [])
      {:ok, <<0, 1, 0, 2, 0x11, 0x11>>}

      iex> ArtNet.Encoder.encode_list([1, 2, 0x1111], :uint8, [])
      :error
  """
  @spec encode_list([any], atom, Keyword.t()) :: {:ok, binary} | :error
  def encode_list(values, format, opts) do
    fun = fn value -> encode(value, format, opts) end

    case do_encode_list(values, [], fun, opts) do
      :error -> :error
      {:ok, encoded_list} -> {:ok, IO.iodata_to_binary(encoded_list)}
    end
  end

  defp do_encode_list([], acc, _, _), do: {:ok, Enum.reverse(acc)}

  defp do_encode_list([value | rest], acc, fun, opts) do
    case fun.(value) do
      {:ok, encoded} -> do_encode_list(rest, [encoded | acc], fun, opts)
      :error -> :error
    end
  end

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
