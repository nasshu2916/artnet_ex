defmodule ArtNet do
  @moduledoc """
  This is the main module for the ArtNet library.

  This library is used to encode and decode Art-Net packets.

  Art-Net is a protocol for transmitting DMX data over IP networks. It is used in the entertainment industry to control lighting equipment such as dimmers, moving lights, and LED fixtures.

  Note: This library provides encode/decode functionality. It does not provide network transfer functionality.
  """

  @artnet_identifier ArtNet.Packet.identifier()

  @doc """
  Decodes a binary Art-Net packet.

  ## Examples
  ```
  iex> ArtNet.decode(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  {:ok,
    %ArtNet.Packet.ArtDmx{
      sequence: 01,
      physical: 0,
      sub_universe: 0,
      net: 0,
      length: 1,
      data: [255]
    }}

  iex> ArtNet.decode(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x01, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  {:error, %ArtNet.DecodeError{reason: {:invalid_data, "Invalid identifier"}}}

  iex> ArtNet.decode(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x51, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  {:error, %ArtNet.DecodeError{reason: {:invalid_op_code, 0x5100}}}

  iex> ArtNet.decode(<<0x01, 0x02>>)
  {:error, %ArtNet.DecodeError{reason: {:invalid_data, "Invalid identifier"}}}
  ```
  """
  @spec decode(binary) :: {:ok, struct} | {:error, ArtNet.DecodeError.t()}
  def decode(<<@artnet_identifier, op_code::little-size(16), _rest::binary>> = data) do
    case ArtNet.OpCode.packet_module_from_value(op_code) do
      nil -> {:error, %ArtNet.DecodeError{reason: {:invalid_op_code, op_code}}}
      module -> module.decode(data)
    end
  end

  def decode(_) do
    {:error, %ArtNet.DecodeError{reason: {:invalid_data, "Invalid identifier"}}}
  end

  @doc """
  Decodes a binary Art-Net packet.

  If the packet could not be decoded, the function raises an error.

  ## Examples
  ```
  iex> ArtNet.decode!(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  %ArtNet.Packet.ArtDmx{sequence: 1, physical: 0, sub_universe: 0, net: 0, length: 1, data: [255]}
  """
  @spec decode!(binary) :: struct
  def decode!(binary) do
    case decode(binary) do
      {:ok, packet} -> packet
      {:error, error} -> raise error
    end
  end

  @spec encode(struct) :: {:ok, binary} | {:error, ArtNet.EncodeError.t()}
  def encode(packet) do
    ArtNet.Packet.encode(packet)
  end

  @doc """
  Encodes a binary Art-Net packet.

  If the packet could not be encoded, the function raises an error.

  ## Examples
  ```
  iex> ArtNet.encode!(%ArtNet.Packet.ArtDmx{sequence: 1, physical: 0, sub_universe: 0, net: 0, length: 1, data: [255]})
  <<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>
  ```
  """
  @spec encode!(struct) :: binary
  def encode!(packet) do
    case encode(packet) do
      {:ok, binary} -> binary
      {:error, error} -> raise error
    end
  end

  @doc """
  Fetches the Art-Net packet opcode from a binary packet.

  ## Examples
  ```
  iex> ArtNet.fetch_op_code(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  :op_dmx

  iex> ArtNet.fetch_op_code(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x01, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  :error

  iex> ArtNet.fetch_op_code(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x51, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  :error
  """
  @spec fetch_op_code(binary) :: ArtNet.OpCode.keys() | :error
  def fetch_op_code(<<@artnet_identifier, op_code::little-size(16), _rest::binary>>) do
    case ArtNet.OpCode.op_code_type(op_code) do
      nil -> :error
      op_code -> op_code
    end
  end

  def fetch_op_code(_) do
    :error
  end
end
