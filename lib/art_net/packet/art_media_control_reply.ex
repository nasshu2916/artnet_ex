defmodule ArtNet.Packet.ArtMediaControlReply do
  @moduledoc """
  Reports media control state from a media server.

  Media servers send this packet in response to media control activity.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:filler3, {:integer, 8}, default: 0)
    field(:filler4, {:integer, 8}, default: 0)
    field(:stream, {:integer, 8})
    field(:reply_command, {:integer, 8})
    field(:max_clips, {:integer, 16})
    field(:time_code_day, {:integer, 8})
    field(:time_code_hour, {:integer, 8})
    field(:time_code_minute, {:integer, 8})
    field(:time_code_second, {:integer, 8})
    field(:time_code_frames, {:integer, 8})
    field(:time_code_mode, {:integer, 8})
    field(:status1, {:integer, 8})
    field(:status2, {:integer, 8}, default: 0)
    field(:status3, {:integer, 8}, default: 0)
    field(:status4, {:integer, 8}, default: 0)
    field(:data, [{:integer, 8}])
  end

  def validate(%{data: data}) when length(data) in 1..128, do: :ok
  def validate(_), do: {:error, "Data length must be 1..128 bytes"}
end
