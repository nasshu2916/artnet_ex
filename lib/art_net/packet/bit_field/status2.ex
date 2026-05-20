defmodule ArtNet.Packet.BitField.Status2 do
  @moduledoc """
  Status2 bit field used by `ArtNet.Packet.ArtPollReply`.

  This field reports additional node capabilities and runtime state.

    * `:support_browser` - node supports web browser configuration.
    * `:dhcp` - node is currently using DHCP.
    * `:dhcp_capable` - node can use DHCP.
    * `:port_15bit` - node supports 15-bit Port-Address fields.
    * `:can_switch` - output style can be switched.
    * `:squawking` - node is currently squawking.
    * `:switch_output_style` - output style switch is active.
    * `:control_rdm` - RDM can be controlled.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
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
