defmodule ArtNet do
  @moduledoc """
  This is the main module for the ArtNet library.

  This library is used to encode and decode Art-Net packets.

  Art-Net is a protocol for transmitting DMX data over IP networks. It is used in the entertainment industry to control lighting equipment such as dimmers, moving lights, and LED fixtures.

  Note: This library provides encode/decode functionality. It does not provide network transfer functionality.
  """

  alias ArtNet.{Packet, OpCode}

  @artnet_identifier ArtNet.Packet.identifier()

  @type packet :: struct

  defdelegate decode(data), to: Packet
  defdelegate decode!(data), to: Packet

  defdelegate encode(packet), to: Packet
  defdelegate encode!(packet), to: Packet

  @doc """
  Fetches the Art-Net packet opcode from a binary packet.

  ## Examples
  iex> ArtNet.fetch_op_code(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  :op_dmx

  iex> ArtNet.fetch_op_code(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x01, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  :error

  iex> ArtNet.fetch_op_code(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x51, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  :error
  """
  @spec fetch_op_code(binary) :: {:ok, OpCode.type()} | :error
  def fetch_op_code(<<@artnet_identifier, op_code::little-size(16), _rest::binary>>) do
    case OpCode.op_code_type(op_code) do
      nil -> :error
      op_code -> op_code
    end
  end

  def fetch_op_code(_) do
    :error
  end
end
