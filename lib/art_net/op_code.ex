defmodule ArtNet.OpCode do
  alias ArtNet.Packet

  # Define the op codes for the Art-Net protocol
  @op_code_config %{
    op_poll: {0x2000, Packet.ArtPoll},
    op_poll_reply: {0x2100, Packet.ArtPollReply},
    op_diag_data: {0x2300, Packet.ArtDiagData},
    op_command: {0x2400, Packet.ArtCommand},
    op_data_request: {0x2700, Packet.ArtDataRequest},
    op_data_reply: {0x2800, Packet.ArtDataReply},
    op_dmx: {0x5000, Packet.ArtDmx},
    op_nzs: {0x5100, Packet.ArtNzs},
    op_sync: {0x5200, Packet.ArtSync},
    op_address: {0x6000, Packet.ArtAddress},
    op_input: {0x7000, Packet.ArtInput},
    op_tod_request: {0x8000, Packet.ArtTodRequest},
    op_tod_data: {0x8100, Packet.ArtTodData},
    op_tod_control: {0x8200, Packet.ArtTodControl},
    op_rdm: {0x8300, Packet.ArtRdm},
    op_rdm_sub: {0x8400, Packet.ArtRdmSub},
    op_media: {0x9000, Packet.ArtMedia},
    op_media_patch: {0x9100, Packet.ArtMediaPatch},
    op_media_control: {0x9200, Packet.ArtMediaControl},
    op_media_control_reply: {0x9300, Packet.ArtMediaControlReply},
    op_time_code: {0x9700, Packet.ArtTimeCode},
    op_time_sync: {0x9800, Packet.ArtTimeSync},
    op_trigger: {0x9900, Packet.ArtTrigger},
    op_directory: {0x9A00, Packet.ArtDirectory},
    op_directory_reply: {0x9B00, Packet.ArtDirectoryReply},
    op_video_setup: {0xA010, Packet.ArtVideoSetup},
    op_video_palette: {0xA020, Packet.ArtVideoPalette},
    op_video_data: {0xA040, Packet.ArtVideoData},
    op_mac_master: {0xF000, Packet.ArtMacMaster},
    op_mac_slave: {0xF100, Packet.ArtMacSlave},
    op_firmware_master: {0xF200, Packet.ArtFirmwareMaster},
    op_firmware_reply: {0xF300, Packet.ArtFirmwareReply},
    op_file_tn_master: {0xF400, Packet.ArtFileTnMaster},
    op_file_fn_master: {0xF500, Packet.ArtFileFnMaster},
    op_file_fn_reply: {0xF600, Packet.ArtFileFnReply},
    op_ip_prog: {0xF800, Packet.ArtIpProg},
    op_ip_prog_reply: {0xF900, Packet.ArtIpProgReply}
  }

  # Define the op codes as atoms
  @op_codes Map.keys(@op_code_config)

  @type type :: unquote(ArtNet.Packet.Schema.Types.type_ast(@op_codes))

  @doc """
  Returns the Packet module for the given op code.
  If the op code is not supported, nil is returned.
  """
  for {_name, {code, packet_module}} <- @op_code_config do
    def packet_module_from_value(unquote(code)), do: unquote(packet_module)
  end

  def packet_module_from_value(_), do: nil

  for {name, {code, _}} <- @op_code_config do
    def op_code_type(unquote(code)), do: unquote(name)
  end

  def op_code_type(_), do: nil

  for {name, {code, packet_module}} <- @op_code_config do
    def op_code(unquote(packet_module)), do: unquote(code)
    def op_code(unquote(name)), do: unquote(code)
  end
end
