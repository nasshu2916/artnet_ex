defmodule ArtNet do
  @moduledoc """
  This is the main module for the ArtNet library.

  This library is used to encode and decode Art-Net packets.

  Art-Net is a protocol for transmitting DMX data over IP networks. It is used in the entertainment industry to control lighting equipment such as dimmers, moving lights, and LED fixtures.

  Note: This library provides endode/decode functionality. It does not provide network transfer functionality.
  """

  @art_net_identifier ArtNet.Packet.identifier()

  @doc """
  Decodes a binary Art-Net packet.

  ## Examples
  ```
  iex> ArtNet.decode(<<0x41, 0x72, 0x74, 0x2D, 0x4E, 0x65, 0x74, 0x00, 0x00, 0x50, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0xFF>>)
  {:ok,
    %ArtNet.Packet.ArtDmx{
      id: <<65, 114, 116, 45, 78, 101, 116, 0>>,
      op_code: 0x5000,
      version: 0x14,
      sequence: 01,
      physical: 0,
      sub_universe: 0,
      net: 0,
      length: 1,
      data: <<255>>
    }}
  ```
  """

  def decode(<<@art_net_identifier, op_code::little-size(16), _rest::binary>> = packet) do
    case op_code do
      0x2000 -> ArtNet.Packet.ArtPoll.decode(packet)
      0x2100 -> ArtNet.Packet.ArtPollReply.decode(packet)
      0x5000 -> ArtNet.Packet.ArtDmx.decode(packet)
      _ -> :error
    end
  end

  def decode(_) do
    :error
  end

  @spec encode(struct) :: {:ok, binary} | :error
  def encode(packet) do
    ArtNet.Packet.encode(packet)
  end
end
