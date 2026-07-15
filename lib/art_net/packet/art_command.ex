defmodule ArtNet.Packet.ArtCommand do
  @moduledoc """
  Sends text-based parameter commands to Art-Net devices.

  The command payload is carried as bytes in `data`; `length` must match the
  number of payload bytes.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: 0x2400 do
    field(:esta_manufacturer, {:integer, 16},
      description: "ESTA manufacturer code for the command data."
    )

    field(:length, {:integer, 16}, description: "Number of command data bytes.")
    field(:data, [{:integer, 8}], description: "Manufacturer-specific command payload.")
  end

  @impl ArtNet.Packet.Schema
  def validate(%{length: length, data: data}) do
    cond do
      length != length(data) ->
        {:error, "Data length does not match the length field"}

      length > 512 ->
        {:error, "Data length must be 512 or less"}

      true ->
        :ok
    end
  end
end
