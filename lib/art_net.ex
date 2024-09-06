defmodule ArtNet do
  @moduledoc """
  This is the main module for the ArtNet library.

  This library is used to encode and decode Art-Net packets.

  Art-Net is a protocol for transmitting DMX data over IP networks. It is used in the entertainment industry to control lighting equipment such as dimmers, moving lights, and LED fixtures.

  Note: This library provides encode/decode functionality. It does not provide network transfer functionality.
  """

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
  ```
  """

  def decode(<<_::binary-size(8), op_code::little-size(16), _rest::binary>> = data) do
    case ArtNet.OpCode.packet_module_from_value(op_code) do
      nil -> {:error, %ArtNet.DecodeError{reason: {:invalid_op_code, op_code}}}
      module -> module.decode(data)
    end
  end

  def decode(_) do
    {:error, %ArtNet.DecodeError{reason: :invalid_data}}
  end

  @spec encode(struct) :: {:ok, binary} | :error
  def encode(packet) do
    ArtNet.Packet.encode(packet)
  end
end
