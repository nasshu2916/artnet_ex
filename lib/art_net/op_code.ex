defmodule ArtNet.OpCode do
  alias ArtNet.Packet

  # Define the op codes for the Art-Net protocol
  @op_code_config %{
    op_poll: {0x2000, Packet.ArtPoll},
    op_poll_reply: {0x2100, Packet.ArtPollReply},
    op_dmx: {0x5000, Packet.ArtDmx}
  }

  # Define the op codes as atoms
  @op_codes Map.keys(@op_code_config)

  @doc """
  Returns the op codes as atoms.
  """
  def op_codes, do: @op_codes

  @doc """
  Returns the Packet module for the given op code.
  If the op code is not supported, nil is returned.
  """
  for {_name, {code, packet_module}} <- @op_code_config do
    def packet_module_from_value(unquote(code)), do: unquote(packet_module)
  end

  def packet_module_from_value(_), do: nil
end
