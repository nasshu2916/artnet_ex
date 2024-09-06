defmodule ArtNet.DecodeError do
  @type t :: %__MODULE__{
          reason:
            {:decode_error, atom}
            | {:validate_error, String.t()}
            | {:excess_bytes, binary}
            | {:invalid_op_code, pos_integer}
            | :invalid_data
        }

  defexception [:reason]

  def message(%__MODULE__{} = exception) do
    case exception.reason do
      {:decode_error, reason} -> "decoding error: #{inspect(reason)}"
      {:excess_bytes, bytes} -> "found excess bytes: #{inspect(bytes)}"
      {:validate_error, reason} -> "validation error: #{reason}"
      {:invalid_op_code, op_code} -> "not supported op code: #{op_code}"
      :invalid_data -> "invalid data"
    end
  end
end

defmodule ArtNet.Decoder do
  @spec decode(binary, format :: atom | [atom], Keyword.t()) :: {:ok, {any, binary}} | :error
  def decode(data, [format], opts), do: decode_list(data, format, opts)

  def decode(data, :uint8, _opts), do: integer(data, 8)
  def decode(data, :uint16, _opts), do: integer(data, 16)

  def decode(data, :binary, opt), do: binary(data, Keyword.get(opt, :size))

  def decode(data, :string, opt), do: string(data, Keyword.get(opt, :size))

  @doc """
  Decodes a list of values from a binary.

  This function is used to decode a list of values from a binary.

  - `data` is the binary to decode the values from.
  - `format` is the format of the values.
  - `opts` is a keyword of format options.
    + `length` is the number of values to decode. If `nil`, all values are decoded.

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

      iex> ArtNet.Decoder.decode_list(<<0, 1, 1>>, :uint8, [length: 2])
      {:ok, {[0, 1], <<1>>}}
  """
  @spec decode_list(binary, atom, Keyword.t()) :: {:ok, {list, binary}} | :error
  def decode_list(data, format, opts) do
    fun = fn rest -> decode(rest, format, opts) end
    length = Keyword.get(opts, :length)

    case do_decode_list(data, [], fun, 0, length, opts) do
      :error -> :error
      {:ok, result} -> {:ok, result}
    end
  end

  def do_decode_list(rest, acc, _, count, count, _), do: {:ok, {Enum.reverse(acc), rest}}
  def do_decode_list(<<>>, acc, _, _, nil, _), do: {:ok, {Enum.reverse(acc), <<>>}}

  def do_decode_list(data, acc, fun, count, length, opts) do
    case fun.(data) do
      {:ok, {value, rest}} -> do_decode_list(rest, [value | acc], fun, count + 1, length, opts)
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

  @doc """
  Extracts a string value from a binary.

  This function is used to extract string values from a binary.

  - `data` is the binary to extract the string from.
  - `size` is the size of the string in bytes. If `nil`, the entire binary is extracted.

  The function returns `{:ok, {value, rest}}` if the string was successfully extracted.
  The `value` is the extracted string and `rest` is the remaining binary.

  The function trims trailing null bytes from the string.

  ## Examples
      iex> ArtNet.Decoder.string(<<65, 66, 67, 0, 0>>, nil)
      {:ok, {"ABC", <<>>}}

      iex> ArtNet.Decoder.string(<<65, 66, 67, 0, 0>>, 2)
      {:ok, {"AB", <<67, 0, 0>>}}

      iex> ArtNet.Decoder.string(<<65, 66, 67, 0, 0>>, 4)
      {:ok, {"ABC", <<0>>}}

      iex> ArtNet.Decoder.string(<<65, 66, 0, 67, 0, 0>>, 5)
      {:ok, {"AB\0C", <<0>>}}

      iex> ArtNet.Decoder.string(<<65, 66, 67, 255, 0>>, 4)
      {:ok, {<<65, 66, 67, 255>>, <<0>>}}

      iex ArtNet.Decoder.string(<<65, 66, 67, 0, 0>>, 6)
      :error
  """
  @spec string(binary, pos_integer | nil) :: {:ok, {String.t(), binary}} | :error
  def string(data, size) do
    case binary(data, size) do
      {:ok, {string, rest}} ->
        {:ok, {String.trim_trailing(string, <<0>>), rest}}

      :error ->
        :error
    end
  end
end
