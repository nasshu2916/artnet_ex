defmodule ArtNet.Packet.ArtDataRequest do
  @moduledoc """
  Requests manufacturer-specific data from a device.

  The `esta_manufacturer`, `oem`, and `request` fields identify the data being
  requested, such as product URLs or other vendor-defined records.
  """

  use ArtNet.Packet.Schema

  defpacket do
    field(:esta_manufacturer, {:integer, 16})
    field(:oem, {:integer, 16})
    field(:request, {:integer, 16})
    field(:spare, {:binary, 22}, default: <<0::size(176)>>)
  end
end
