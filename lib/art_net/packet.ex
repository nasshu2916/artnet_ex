defmodule ArtNet.Packet do
  alias ArtNet.OpCode

  @identifier "Art-Net" <> <<0>>
  @version 14

  def identifier, do: @identifier
  def version, do: @version

  @doc """
  Decodes a binary Art-Net packet.

  ## Examples
  iex> ArtNet.Packet.decode(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  {:ok,
    %ArtNet.Packet.ArtDmx{
      sequence: 01,
      physical: 0,
      sub_universe: 0,
      net: 0,
      length: 1,
      data: [255]
    }}

  iex> ArtNet.Packet.decode(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x01, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  {:error, %ArtNet.DecodeError{reason: {:invalid_data, "Invalid identifier"}}}

  iex> ArtNet.Packet.decode(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x51, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  {:error, %ArtNet.DecodeError{reason: {:invalid_op_code, 0x5100}}}

  iex> ArtNet.Packet.decode(<<0x01, 0x02>>)
  {:error, %ArtNet.DecodeError{reason: {:invalid_data, "Invalid identifier"}}}
  """
  @spec decode(binary) :: {:ok, struct} | {:error, ArtNet.DecodeError.t()}
  def decode(<<@identifier, op_code::little-size(16), _rest::binary>> = data) do
    case OpCode.packet_module_from_value(op_code) do
      nil -> {:error, %ArtNet.DecodeError{reason: {:invalid_op_code, op_code}}}
      module -> decode(module, data)
    end
  end

  def decode(_) do
    {:error, %ArtNet.DecodeError{reason: {:invalid_data, "Invalid identifier"}}}
  end

  @doc """
  Decodes a binary Art-Net packet.

  If the packet could not be decoded, the function raises an error.

  ## Examples
  iex> ArtNet.Packet.decode!(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  %ArtNet.Packet.ArtDmx{sequence: 1, physical: 0, sub_universe: 0, net: 0, length: 1, data: [255]}
  """
  @spec decode!(binary) :: struct
  def decode!(binary) do
    case decode(binary) do
      {:ok, packet} -> packet
      {:error, error} -> raise error
    end
  end

  @spec decode(module, binary) :: {:ok, struct} | {:error, ArtNet.DecodeError.t()}
  def decode(module, rest) do
    with {:ok, rest} <- validate_header(module, rest),
         {:ok, packet} <- decode_body(module, rest),
         :ok <- module.validate(packet) do
      {:ok, packet}
    else
      {:error, %ArtNet.DecodeError{} = error} ->
        {:error, error}

      {:error, reason} when is_binary(reason) ->
        {:error, %ArtNet.DecodeError{reason: {:invalid_data, reason}}}
    end
  end

  @spec decode_body(module, binary) :: {:ok, struct} | {:error, ArtNet.DecodeError.t()}
  defp decode_body(module, rest), do: module.__decode_body__(rest)

  @spec validate_header(module, binary) :: {:ok, binary} | {:error, ArtNet.DecodeError.t()}
  def validate_header(module, rest) do
    with {:ok, rest} <- validate_identifier(rest),
         {:ok, rest} <- validate_op_code(module, rest),
         {:ok, rest} <- validate_version(module, rest) do
      {:ok, rest}
    else
      {:error, reason} -> {:error, %ArtNet.DecodeError{reason: {:invalid_data, reason}}}
    end
  end

  defp validate_identifier(data) do
    case data do
      <<@identifier, rest::binary>> -> {:ok, rest}
      _ -> {:error, "Invalid identifier"}
    end
  end

  defp validate_op_code(module, data) do
    op_code = module.op_code()

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

  @spec encode(ArtNet.packet()) :: {:ok, binary} | {:error, ArtNet.EncodeError.t()}
  def encode(packet) do
    with {{:ok, module}, _} <- {fetch_module(packet), "packet is not a struct"},
         :ok <- module.validate(packet),
         header = encode_header(module),
         {:ok, body} <- encode_body(packet) do
      {:ok, header <> body}
    else
      {:error, %ArtNet.EncodeError{} = reason} ->
        {:error, reason}

      {:error, reason} when is_binary(reason) ->
        {:error, %ArtNet.EncodeError{reason: {:invalid_data, reason}}}
    end
  end

  @doc """
  Encodes a binary Art-Net packet.

  If the packet could not be encoded, the function raises an error.

  ## Examples
  iex> ArtNet.Packet.encode!(%ArtNet.Packet.ArtDmx{sequence: 1, physical: 0, sub_universe: 0, net: 0, length: 1, data: [255]})
  <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>
  """
  @spec encode(ArtNet.packet()) :: binary
  def encode!(packet) do
    case encode(packet) do
      {:ok, binary} -> binary
      {:error, %ArtNet.EncodeError{} = error} -> raise error
    end
  end

  @spec fetch_module(struct) :: {:ok, module} | :error
  defp fetch_module(%{__struct__: module}), do: {:ok, module}
  defp fetch_module(_), do: :error

  @spec encode_header(module) :: binary
  defp encode_header(module) do
    op_code = module.op_code()

    if module.require_version_header?() do
      <<@identifier, op_code::little-integer-size(16), @version::integer-size(16)>>
    else
      <<@identifier, op_code::little-integer-size(16)>>
    end
  end

  @spec encode_body(struct) :: {:ok, binary} | {:error, ArtNet.EncodeError.t()}
  defp encode_body(packet), do: packet.__struct__.__encode_body__(packet)
end
