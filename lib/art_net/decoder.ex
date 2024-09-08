defmodule ArtNet.DecodeError do
  @type t :: %__MODULE__{
          reason:
            {:decode_error, atom}
            | {:invalid_data, String.t()}
            | {:excess_bytes, binary}
            | {:invalid_op_code, pos_integer}
        }

  defexception [:reason]

  def message(%__MODULE__{} = exception) do
    case exception.reason do
      {:decode_error, reason} -> "decoding error: #{inspect(reason)}"
      {:excess_bytes, bytes} -> "found excess bytes: #{inspect(bytes, base: :hex)}"
      {:invalid_data, reason} -> "invalid data: #{reason}"
      {:invalid_op_code, op_code} -> "not supported op code: #{inspect(op_code, base: :hex)}"
    end
  end
end

defmodule ArtNet.Decoder do
  @spec decode(binary, ArtNet.Packet.Schema.format(), Keyword.t()) ::
          {:ok, {any, binary}} | :error
  def decode(data, [format], opts), do: decode_list(data, format, opts)

  def decode(data, {:integer, size}, _opts), do: integer(data, size)
  def decode(data, {:integer, size, :little_endian}, _opts), do: little_integer(data, size)

  def decode(data, {:binary, size}, _opts), do: binary(data, size)

  def decode(data, {:string, size}, _opts), do: string(data, size)

  def decode(data, {:enum_table, module}, _opts), do: enum_table(data, module)
  def decode(data, {:bit_field, module}, _opts), do: bit_field(data, module)

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
      iex> ArtNet.Decoder.decode_list(<<1, 2, 3>>, {:integer, 8}, [])
      {:ok, {[1, 2, 3], <<>>}}

      iex> ArtNet.Decoder.decode_list(<<1, 2, 3>>, {:integer, 16}, [])
      :error

      iex> ArtNet.Decoder.decode_list(<<0, 1, 1, 1>>, {:integer, 16}, [])
      {:ok, {[1, 0x0101], <<>>}}

      iex> ArtNet.Decoder.decode_list(<<0, 1, 1>>, {:integer, 8}, [length: 2])
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
  Extracts a little-endian integer value from a binary.

  This function is used to extract little-endian integer values from a binary.

  ## Examples
      iex> ArtNet.Decoder.little_integer(<<1, 2, 3, 4>>, 16)
      {:ok, {0x0201, <<3, 4>>}}

      iex> ArtNet.Decoder.little_integer(<<1, 2, 3, 4>>, 32)
      {:ok, {0x04030201, <<>>}}

      iex> ArtNet.Decoder.little_integer(<<1, 2, 3, 4>>, 5)
      :error

      iex> ArtNet.Decoder.little_integer(<<1, 2, 3>>, 32)
      :error
  """
  @spec little_integer(binary, pos_integer) :: {:ok, {non_neg_integer, binary}} | :error
  def little_integer(data, size) do
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

  @doc """
  Enumerates a table of values from a binary.

  This function is used to enumerate a table of values from a binary.

  - `data` is the binary to enumerate the table from.
  - `module` is the module that defines the enum.

  The function returns `{:ok, {atom, rest}}` if the table was successfully enumerated.
  The `atom` is the enumerated atom and `rest` is the remaining binary.

  If the table could not be enumerated, the function returns `:error`.

  ## Examples
      iex> ArtNet.Decoder.enum_table(<<0x00, 0x00>>, ArtNet.Packet.EnumTable.Priority)
      {:ok, {:dp_all, <<0x00>>}}

      iex> ArtNet.Decoder.enum_table(<<0xC0, 0x10>>, ArtNet.Packet.EnumTable.Priority)
      {:ok, {:dp_high, <<0x10>>}}

      iex> ArtNet.Decoder.enum_table(<<0x01, 0x00>>, ArtNet.Packet.EnumTable.Priority)
      :error
  """
  # @spec enum_table(binary, Keyword.t()) :: {:ok, {atom, binary}} | :error
  def enum_table(data, module) do
    bit_size = module.bit_size()

    case data do
      <<value::size(bit_size), rest::binary>> ->
        case module.to_atom(value) do
          {:ok, atom} -> {:ok, {atom, rest}}
          :error -> :error
        end

      _ ->
        :error
    end
  end

  @doc """
  Extracts a bit field from a binary.

  This function is used to extract a bit field from a binary.

  - `data` is the binary to extract the bit field from.
  - `module` is the module that defines the bit field.

  The function returns `{:ok, {struct, rest}}` if the bit field was successfully extracted.
  The `struct` is the extracted struct and `rest` is the remaining binary.

  If the bit field could not be extracted, the function returns `:error`.

  ## Examples
      iex> ArtNet.Decoder.bit_field(<<0b00110, 0b0001>>, ArtNet.Packet.BitField.TalkToMe)
      {:ok,
        {%ArtNet.Packet.BitField.TalkToMe{
            reply_on_change: true,
            diagnostics: true,
            diag_unicast: false,
            vlc: false
          }, <<0x01>>}}
  """

  @spec bit_field(binary, module) :: {:ok, {struct(), binary}} | :error
  def bit_field(data, module) do
    bit_size = module.bit_size()

    case data do
      <<value::size(bit_size), rest::binary>> ->
        {:ok, {do_bit_field(value, module), rest}}

      _ ->
        :error
    end
  end

  defp do_bit_field(value, module) do
    module.bit_field_schema()
    |> Enum.reduce_while([], fn {key, {type, {offset, length}}}, acc ->
      extracted_value = ArtNet.Packet.BitField.extract_bits(value, offset, length)

      case {type, extracted_value} do
        {:boolean, 0} -> {:ok, false}
        {:boolean, 1} -> {:ok, true}
        {{:enum_table, enum_module}, extracted_value} -> enum_module.to_atom(extracted_value)
      end
      |> case do
        {:ok, result} -> {:cont, [{key, result} | acc]}
        :error -> {:halt, :error}
      end
    end)
    |> case do
      :error -> :error
      acc -> struct!(module, acc)
    end
  end
end
