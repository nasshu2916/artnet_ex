defmodule ArtNet.Packet.ArtDataReply do
  use ArtNet.Packet.Schema

  defpacket do
    field(:esta_manufacturer, {:integer, 16})
    field(:oem, {:integer, 16})
    field(:request, {:integer, 16})
    field(:payload_length, {:integer, 16})
    field(:payload, [{:integer, 8}])
  end

  @impl ArtNet.Packet.Schema
  def validate(%{payload_length: length, payload: payload}) do
    cond do
      length != length(payload) ->
        {:error, "Payload length does not match the payload_length field"}

      length > 512 ->
        {:error, "Payload length must be 512 or less"}

      true ->
        :ok
    end
  end
end
