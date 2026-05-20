defmodule ArtNet.Packet.ArtMediaControl do
  use ArtNet.Packet.Schema

  defpacket do
    field(:filler1, {:integer, 8}, default: 0)
    field(:filler2, {:integer, 8}, default: 0)
    field(:filler3, {:integer, 8}, default: 0)
    field(:filler4, {:integer, 8}, default: 0)
    field(:stream, {:integer, 8})
    field(:control_command, {:integer, 8})
    field(:command_data1, {:integer, 8}, default: 0)
    field(:command_data2, {:integer, 8}, default: 0)
    field(:command_data3, {:integer, 8}, default: 0)
    field(:command_data4, {:integer, 8}, default: 0)
    field(:command_data5, {:integer, 8}, default: 0)
    field(:command_data6, {:integer, 8}, default: 0)
  end
end
