defmodule ArtNet.Packet.BitField.PortType do
  @moduledoc """
  PortType bit field used by `ArtNet.Packet.ArtPollReply`.

  The low bits store the protocol type through
  `ArtNet.Packet.EnumTable.PortType`; the high bits indicate whether the port
  supports input and/or output.
  """

  use ArtNet.Packet.BitField

  alias ArtNet.Packet.EnumTable

  defbitfield bit_size: 8 do
    field(:port_type, {:enum_table, EnumTable.PortType},
      description: "Protocol used by the port."
    )

    field(:input, :boolean, description: "Port can receive data.")
    field(:output, :boolean, description: "Port can transmit data.")
  end
end
