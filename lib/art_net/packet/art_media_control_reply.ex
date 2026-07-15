defmodule ArtNet.Packet.ArtMediaControlReply do
  @moduledoc """
  Reports media control state from a media server.

  Media servers send this packet in response to media control activity.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: 0x9300 do
    field(:filler1, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler2, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler3, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:filler4, {:integer, 8}, default: 0, description: "Reserved byte, transmitted as zero.")
    field(:stream, {:integer, 8}, description: "Media stream identifier.")
    field(:reply_command, {:integer, 8}, description: "Media control reply command code.")
    field(:max_clips, {:integer, 16}, description: "Maximum number of clips supported.")
    field(:time_code_day, {:integer, 8}, description: "Current media time-code day value.")
    field(:time_code_hour, {:integer, 8}, description: "Current media time-code hour value.")
    field(:time_code_minute, {:integer, 8}, description: "Current media time-code minute value.")
    field(:time_code_second, {:integer, 8}, description: "Current media time-code second value.")
    field(:time_code_frames, {:integer, 8}, description: "Current media time-code frame value.")
    field(:time_code_mode, {:integer, 8}, description: "Current media time-code mode.")
    field(:status1, {:integer, 8}, description: "Primary media status byte.")
    field(:status2, {:integer, 8}, default: 0, description: "Secondary media status byte.")
    field(:status3, {:integer, 8}, default: 0, description: "Tertiary media status byte.")
    field(:status4, {:integer, 8}, default: 0, description: "Quaternary media status byte.")
    field(:data, [{:integer, 8}], description: "Additional media reply data bytes.")
  end

  def validate(%{data: data}) when length(data) in 1..128, do: :ok
  def validate(_), do: {:error, "Data length must be 1..128 bytes"}
end
