defmodule ArtNet.Packet.BitField.Status2 do
  @moduledoc """
  Status2 bit field used by `ArtNet.Packet.ArtPollReply`.

  This field reports additional node capabilities and runtime state.
  """

  use ArtNet.Packet.BitField

  defbitfield bit_size: 8 do
    field(:support_browser, :boolean, description: "Node supports web browser configuration.")
    field(:dhcp, :boolean, description: "Node is currently using DHCP.")
    field(:dhcp_capable, :boolean, description: "Node can use DHCP.")
    field(:port_15bit, :boolean, description: "Node supports 15-bit Port-Address fields.")
    field(:can_switch, :boolean, description: "Output style can be switched.")
    field(:squawking, :boolean, description: "Node is currently squawking.")
    field(:switch_output_style, :boolean, description: "Output style switch is active.")
    field(:control_rdm, :boolean, description: "RDM can be controlled.")
  end
end
