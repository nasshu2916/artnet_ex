defmodule ArtNet.Packet.ArtDataRequest do
  use ArtNet.Packet.Schema

  defpacket do
    field(:esta_manufacturer, {:integer, 16})
    field(:oem, {:integer, 16})
    field(:request, {:integer, 16})
    field(:spare, {:binary, 22}, default: <<0::size(176)>>)
  end
end
