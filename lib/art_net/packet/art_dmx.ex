defmodule ArtNet.Packet.ArtDmx do
  use ArtNet.Packet.Schema

  defpacket op_code: 0x5000 do
    field(:sequence, :uint8, default: 0)
    field(:physical, :uint8, default: 0)
    field(:sub_universe, :uint8, default: 0)
    field(:net, :uint8, default: 0)
    field(:length, :uint16)
    field(:data, :binary, size: nil)
  end

  @impl ArtNet.Packet.Schema
  def validate(packet) do
    %{length: data_length, data: data} = packet

    if data_length == byte_size(data) do
      :ok
    else
      {:error, "Data length does not match the length field"}
    end
  end
end
