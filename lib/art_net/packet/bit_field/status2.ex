defmodule ArtNet.Packet.BitField.Status2 do
  use ArtNet.Packet.BitField

  defbitfield size: 8 do
    field(:support_browser, :boolean)
    field(:dhcp, :boolean)
    field(:dhcp_capable, :boolean)
    field(:port_15bit, :boolean)
    field(:can_switch, :boolean)
    field(:squawking, :boolean)
    field(:switch_output_style, :boolean)
    field(:control_rdm, :boolean)
  end
end
