defmodule ArtNet.Packet do
  @identifier "Art-Net" <> <<0>>
  @version 14

  def identifier, do: @identifier
  def version, do: @version

  @spec decode(module, binary) :: {:ok, struct} | {:error, ArtNet.DecodeError.t()}
  def decode(module, rest) do
    case validate_header(module, rest) do
      {:ok, rest} -> decode_body(module, rest)
      {:error, reason} -> {:error, reason}
    end
  end

  @spec decode_body(module, binary) :: {:ok, struct} | {:error, ArtNet.DecodeError.t()}
  defp decode_body(module, rest) do
    module.schema()
    |> Enum.reduce_while({:ok, [], rest}, fn {key, {type, opts}}, {:ok, values, rest} ->
      case ArtNet.Decoder.decode(rest, type, opts) do
        {:ok, {value, rest}} ->
          {:cont, {:ok, [{key, value} | values], rest}}

        :error ->
          {:halt, {:error, %ArtNet.DecodeError{reason: {:decode_error, key}}}}
      end
    end)
    |> case do
      {:error, %ArtNet.DecodeError{} = reason} -> {:error, reason}
      {:ok, params, <<>>} -> {:ok, struct!(module, params)}
      {:ok, _, bytes} -> {:error, %ArtNet.DecodeError{reason: {:excess_bytes, bytes}}}
    end
  end

  @spec validate_header(module, binary) :: {:ok, binary} | {:error, ArtNet.DecodeError.t()}
  def validate_header(module, rest) do
    with {:ok, rest} <- validate_identifier(rest),
         {:ok, rest} <- validate_op_code(module, rest),
         {:ok, rest} <- validate_version(module, rest) do
      {:ok, rest}
    else
      {:error, reason} -> {:error, %ArtNet.DecodeError{reason: {:validate_error, reason}}}
    end
  end

  defp validate_identifier(data) do
    case data do
      <<@identifier, rest::binary>> -> {:ok, rest}
      _ -> {:error, "Invalid identifier"}
    end
  end

  defp validate_op_code(module, data) do
    op_code = module.__op_code__()

    case data do
      <<^op_code::little-integer-size(16), rest::binary>> -> {:ok, rest}
      _ -> {:error, "Invalid op code"}
    end
  end

  defp validate_version(module, data) do
    require_version_header? = module.require_version_header?()

    if require_version_header? do
      case data do
        <<@version::integer-size(16), rest::binary>> -> {:ok, rest}
        _ -> {:error, "Invalid version"}
      end
    else
      {:ok, data}
    end
  end

  @spec encode(struct) :: {:ok, binary} | :error
  def encode(packet) do
    case encode_body(packet) do
      {:ok, body} -> {:ok, encode_header(packet.__struct__) <> body}
      :error -> :error
    end
  end

  defp encode_header(module) do
    op_code = module.__op_code__()

    if module.require_version_header?() do
      <<@identifier, op_code::little-integer-size(16), @version::integer-size(16)>>
    else
      <<@identifier, op_code::little-integer-size(16)>>
    end
  end

  defp encode_body(packet) do
    packet.__struct__.schema()
    |> Enum.reduce_while([], fn {key, {type, opts}}, acc ->
      value = Map.fetch!(packet, key)

      case ArtNet.Encoder.encode(value, type, opts) do
        {:ok, data} -> {:cont, [data | acc]}
        :error -> {:halt, :error}
      end
    end)
    |> case do
      :error -> :error
      data -> {:ok, data |> Enum.reverse() |> IO.iodata_to_binary()}
    end
  end
end
