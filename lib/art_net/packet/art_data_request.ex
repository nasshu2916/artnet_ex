defmodule ArtNet.Packet.ArtDataRequest do
  @moduledoc """
  Requests manufacturer-specific data from a device.

  The `esta_manufacturer`, `oem`, and `request` fields identify the data being
  requested, such as product URLs or other vendor-defined records.
  """

  use ArtNet.Packet.Schema

  defpacket op_code: {:op_data_request, 0x2700} do
    field(:esta_manufacturer, {:integer, 16},
      description: "ESTA manufacturer code for the requested data."
    )

    field(:oem, {:integer, 16}, description: "OEM code for the requested data.")
    field(:request, {:integer, 16}, description: "Data request identifier.")

    field(:spare, {:binary, 22},
      default: <<0::size(176)>>,
      description: "Reserved bytes, transmitted as zero."
    )
  end
end
