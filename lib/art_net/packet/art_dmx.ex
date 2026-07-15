defmodule ArtNet.Packet.ArtDmx do
  @moduledoc """
  Transmits zero-start-code DMX512 data for a single universe.

  This packet is also known as ArtOutput. The `length` field must match the
  number of DMX slots carried in `data`.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: 0x5000 do
    field(:sequence, {:integer, 8},
      default: 0,
      description: "Packet sequence number, or 0 to disable sequence checking."
    )

    field(:physical, {:integer, 8},
      default: 0,
      description: "Physical input port that generated the DMX data."
    )

    field(:sub_universe, {:integer, 8},
      default: 0,
      description: "Low byte of the 15-bit Port-Address."
    )

    field(:net, {:integer, 8},
      default: 0,
      description: "Bits 8-14 of the 15-bit Port-Address."
    )

    field(:length, {:integer, 16},
      description: "Number of DMX512 slots included in the data field."
    )

    field(:data, [{:integer, 8}], description: "DMX512 level data, one byte per slot.")
  end

  @impl ArtNet.Packet.Schema
  def validate(packet) do
    %{length: data_length, data: data} = packet

    cond do
      data_length != length(data) ->
        {:error, "Data length does not match the length field"}

      data_length > 512 ->
        {:error, "Data length must be 512 or less"}

      data_length < 1 ->
        {:error, "Data length must be at least 1"}

      true ->
        :ok
    end
  end
end
