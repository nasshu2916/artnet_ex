defmodule ArtNet.Packet.ArtTimeCode do
  use ArtNet.Packet.Schema

  alias ArtNet.Packet.EnumTable

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:stream_id, {:integer, 8}, default: 0)
    field(:frames, {:integer, 8})
    field(:seconds, {:integer, 8})
    field(:minutes, {:integer, 8})
    field(:hours, {:integer, 8})
    field(:type, {:enum_table, EnumTable.TimeCodeType})
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
