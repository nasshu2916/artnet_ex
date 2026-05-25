defmodule ArtNet.Packet.ArtDataReply do
  @moduledoc """
  Replies to `ArtNet.Packet.ArtDataRequest` with manufacturer-specific data.

  The `payload_length` field must match the number of bytes in `payload`.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:esta_manufacturer, {:integer, 16},
      description: "ESTA manufacturer code associated with the data reply."
    )

    field(:oem, {:integer, 16}, description: "OEM code associated with the data reply.")
    field(:request, {:integer, 16}, description: "Data request identifier being answered.")
    field(:payload_length, {:integer, 16}, description: "Number of bytes in the payload field.")
    field(:payload, [{:integer, 8}], description: "Reply payload bytes.")
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
