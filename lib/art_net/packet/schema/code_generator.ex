defmodule ArtNet.Packet.Schema.CodeGenerator do
  @moduledoc false

  alias ArtNet.Packet.Schema

  @type schema :: [{atom, {Schema.Types.format(), Keyword.t()}}]

  @spec generate(schema, Keyword.t()) :: Macro.t()
  def generate(schema, opts) do
    pre_decode_defined? = Keyword.get(opts, :pre_decode_defined?, false)

    quote do
      unquote(default_pre_decode(pre_decode_defined?))
      unquote(decode_body(schema))
      unquote(encode_body(schema))
    end
  end

  @doc false
  @spec encode_result({:ok, binary} | :error | {:error, term}, atom, term, term) ::
          {:ok, binary} | {:error, ArtNet.EncodeError.t()}
  def encode_result({:ok, encoded}, _key, _format, _value), do: {:ok, encoded}

  def encode_result({:error, :not_list}, key, _format, _value) do
    {:error,
     %ArtNet.EncodeError{
       reason: {:invalid_data, "#{key} must be a list"}
     }}
  end

  def encode_result({:error, {:invalid_length, expected, actual}}, key, _format, _value) do
    {:error,
     %ArtNet.EncodeError{
       reason: {:invalid_data, "#{key} must contain #{expected} values, got #{actual}"}
     }}
  end

  def encode_result({:error, {:invalid_element, element}}, key, format, value) do
    encode_element_error(key, format, value, element)
  end

  def encode_result({:error, {:invalid_element, element, _reason}}, key, format, value) do
    encode_element_error(key, format, value, element)
  end

  def encode_result(:error, key, format, value) do
    {:error,
     %ArtNet.EncodeError{
       reason: {:encode_error, %{key: key, type: format, value: value}}
     }}
  end

  defp encode_element_error(key, format, value, element) do
    {:error,
     %ArtNet.EncodeError{
       reason: {:encode_error, %{key: key, type: format, value: value, element: element}}
     }}
  end

  defp default_pre_decode(true), do: []

  defp default_pre_decode(false) do
    quote do
      @impl ArtNet.Packet.Schema
      def pre_decode(body), do: body
    end
  end

  defp decode_body(schema) do
    rest = var(:rest)

    quote do
      @doc false
      @spec __decode_body__(binary) :: {:ok, t()} | {:error, ArtNet.DecodeError.t()}
      def __decode_body__(body) do
        unquote(rest) = pre_decode(body)
        unquote(decode_steps(schema, [], rest))
      end
    end
  end

  defp decode_steps([], decoded_fields, rest) do
    decoded_fields = Enum.reverse(decoded_fields)

    quote do
      case unquote(rest) do
        <<>> -> {:ok, struct!(__MODULE__, unquote(decoded_fields))}
        bytes -> {:error, %ArtNet.DecodeError{reason: {:excess_bytes, bytes}}}
      end
    end
  end

  defp decode_steps([{key, {format, opts}} | fields], decoded_fields, rest) do
    value = field_var(key)

    quote do
      case unquote(decode_call(rest, format, opts)) do
        {:ok, {unquote(value), unquote(rest)}} ->
          unquote(decode_steps(fields, [{key, value} | decoded_fields], rest))

        :error ->
          {:error, %ArtNet.DecodeError{reason: {:decode_error, unquote(key)}}}
      end
    end
  end

  defp encode_body(schema) do
    fields =
      for {key, _} <- schema do
        {key, field_var(key)}
      end

    quote do
      @doc false
      @spec __encode_body__(struct) :: {:ok, binary} | {:error, ArtNet.EncodeError.t()}
      def __encode_body__(%__MODULE__{unquote_splicing(fields)}) do
        unquote(encode_steps(schema, []))
      end
    end
  end

  defp encode_steps([], encoded_fields) do
    encoded_fields = Enum.reverse(encoded_fields)

    quote do
      {:ok, IO.iodata_to_binary(unquote(encoded_fields))}
    end
  end

  defp encode_steps([{key, {format, opts}} | fields], encoded_fields) do
    value = field_var(key)
    encoded = var(:"#{key}_encoded")

    quote do
      case ArtNet.Packet.Schema.CodeGenerator.encode_result(
             unquote(encode_call(value, format, opts)),
             unquote(key),
             unquote(Macro.escape(format)),
             unquote(value)
           ) do
        {:ok, unquote(encoded)} ->
          unquote(encode_steps(fields, [encoded | encoded_fields]))

        {:error, error} ->
          {:error, error}
      end
    end
  end

  defp decode_call(data, [format], opts) do
    rest = var(:list_rest)

    quote do
      ArtNet.Decoder.decode_list_with(
        unquote(data),
        fn unquote(rest) -> unquote(decode_call(rest, format, opts)) end,
        unquote(Macro.escape(opts))
      )
    end
  end

  defp decode_call(data, {:integer, size}, _opts) do
    quote do: ArtNet.Decoder.integer(unquote(data), unquote(size))
  end

  defp decode_call(data, {:integer, size, :little_endian}, _opts) do
    quote do: ArtNet.Decoder.little_integer(unquote(data), unquote(size))
  end

  defp decode_call(data, {:binary, size}, _opts) do
    quote do: ArtNet.Decoder.binary(unquote(data), unquote(size))
  end

  defp decode_call(data, {:string, size}, _opts) do
    quote do: ArtNet.Decoder.string(unquote(data), unquote(size))
  end

  defp decode_call(data, {:enum_table, module}, _opts) do
    quote do: ArtNet.Decoder.enum_table(unquote(data), unquote(module))
  end

  defp decode_call(data, {:bit_field, module}, _opts) do
    quote do: ArtNet.Decoder.bit_field(unquote(data), unquote(module))
  end

  defp encode_call(value, [format], opts) do
    element = var(:list_value)

    quote do
      ArtNet.Encoder.encode_list_with(
        unquote(value),
        fn unquote(element) -> unquote(encode_call(element, format, opts)) end,
        unquote(Macro.escape(opts))
      )
    end
  end

  defp encode_call(value, {:integer, size}, _opts) do
    quote do: ArtNet.Encoder.integer(unquote(value), unquote(size))
  end

  defp encode_call(value, {:integer, size, :little_endian}, _opts) do
    quote do: ArtNet.Encoder.little_integer(unquote(value), unquote(size))
  end

  defp encode_call(value, {:binary, size}, _opts) do
    quote do: ArtNet.Encoder.binary(unquote(value), unquote(size))
  end

  defp encode_call(value, {:string, size}, _opts) do
    quote do: ArtNet.Encoder.binary(unquote(value), unquote(size))
  end

  defp encode_call(value, {:enum_table, module}, _opts) do
    quote do: ArtNet.Encoder.enum_table(unquote(value), unquote(module))
  end

  defp encode_call(value, {:bit_field, _module}, _opts) do
    quote do: ArtNet.Encoder.bit_field(unquote(value))
  end

  defp field_var(key), do: var(key)
  defp var(name), do: Macro.var(name, nil)
end
