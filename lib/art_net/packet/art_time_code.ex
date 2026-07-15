defmodule ArtNet.Packet.ArtTimeCode do
  @moduledoc """
  Transports time code over Art-Net.

  The packet carries frame, seconds, minutes, hours, and time-code type fields.
  """

  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket op_code: {:op_time_code, 0x9700} do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:stream_id, {:integer, 8}, default: 0, description: "Time-code stream identifier.")
    field(:frames, {:integer, 8}, description: "Time-code frame value.")
    field(:seconds, {:integer, 8}, description: "Time-code seconds value.")
    field(:minutes, {:integer, 8}, description: "Time-code minutes value.")
    field(:hours, {:integer, 8}, description: "Time-code hours value.")
    field(:type, {:enum_table, EnumTable.TimeCodeType}, description: "Time-code frame-rate type.")
  end

  @impl ArtNet.Packet.Schema
  def validate(%{frames: frames, seconds: seconds, minutes: minutes, hours: hours}) do
    cond do
      frames < 0 or frames > 29 ->
        {:error, "Frames must be in the range 0..29"}

      seconds < 0 or seconds > 59 ->
        {:error, "Seconds must be in the range 0..59"}

      minutes < 0 or minutes > 59 ->
        {:error, "Minutes must be in the range 0..59"}

      hours < 0 or hours > 23 ->
        {:error, "Hours must be in the range 0..23"}

      true ->
        :ok
    end
  end
end
