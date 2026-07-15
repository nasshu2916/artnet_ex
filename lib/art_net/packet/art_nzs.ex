defmodule ArtNet.Packet.ArtNzs do
  @moduledoc """
  Transmits non-zero-start-code DMX512 data for a single universe.

  This packet carries DMX-style payloads identified by `start_code`, except RDM.
  VLC payloads use start code `0x91` and can be decoded with
  `ArtNet.Packet.ArtVlc.decode/1`.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: {:op_nzs, 0x5100} do
    field(:sequence, {:integer, 8},
      default: 0,
      description: "Packet sequence number, or 0 to disable sequence checking."
    )

    field(:start_code, {:integer, 8}, description: "Non-zero DMX start code for the payload.")

    field(:sub_universe, {:integer, 8},
      default: 0,
      description: "Low byte of the 15-bit Port-Address."
    )

    field(:net, {:integer, 8},
      default: 0,
      description: "Bits 8-14 of the 15-bit Port-Address."
    )

    field(:length, {:integer, 16}, description: "Number of payload data bytes.")
    field(:data, [{:integer, 8}], description: "Non-zero-start-code payload data.")
  end

  @impl ArtNet.Packet.Schema
  def validate(%{start_code: 0}), do: {:error, "Start code must be non-zero"}
  def validate(%{start_code: 0xCC}), do: {:error, "Start code must not be RDM"}

  def validate(%{length: data_length, data: data}) do
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
