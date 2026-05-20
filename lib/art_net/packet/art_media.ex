defmodule ArtNet.Packet.ArtMedia do
  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:filler3, {:integer, 8}, default: 0)
    field(:filler4, {:integer, 8}, default: 0)
    field(:stream, {:integer, 8})
    field(:command, {:integer, 8})
    field(:command_data1, {:integer, 8})
    field(:command_data2, {:integer, 8})
    field(:command_data3, {:integer, 8})
    field(:packs, [{:integer, 8}])
  end

  def validate(%{packs: packs}) when length(packs) <= 240 * 6 and rem(length(packs), 6) == 0,
    do: :ok

  def validate(_), do: {:error, "Packs must contain up to 240 6-byte entries"}
end
