defmodule ArtNet.Packet.BitField.PortType do
  @moduledoc """
  PortType bit field used by `ArtNet.Packet.ArtPollReply`.

  The low bits store the protocol type through
  `ArtNet.Packet.EnumTable.PortType`; the high bits indicate whether the port
  supports input and/or output.

    * `:port_type` - protocol used by the port.
    * `:input` - port can receive data.
    * `:output` - port can transmit data.
  """

  use ArtNet.Packet.BitField

  alias ArtNet.Packet.EnumTable

  defbitfield bit_size: 8 do
    field(:port_type, {:enum_table, EnumTable.PortType})
    field(:input, :boolean)
    field(:output, :boolean)
  end
end
