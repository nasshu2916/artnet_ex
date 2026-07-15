defmodule ArtNet.OpCode do
  @moduledoc """
  OpCode registry for supported Art-Net packet modules.

  The packet codec uses this module to translate between the little-endian
  OpCode value in a binary packet, the public OpCode atom, and the packet
  module that owns the schema.
  """

  alias ArtNet.Packet

  @packet_modules [
    Packet.ArtPoll,
    Packet.ArtPollReply,
    Packet.ArtDiagData,
    Packet.ArtCommand,
    Packet.ArtDataRequest,
    Packet.ArtDataReply,
    Packet.ArtDmx,
    Packet.ArtNzs,
    Packet.ArtSync,
    Packet.ArtAddress,
    Packet.ArtInput,
    Packet.ArtTodRequest,
    Packet.ArtTodData,
    Packet.ArtTodControl,
    Packet.ArtRdm,
    Packet.ArtRdmSub,
    Packet.ArtMedia,
    Packet.ArtMediaPatch,
    Packet.ArtMediaControl,
    Packet.ArtMediaControlReply,
    Packet.ArtTimeCode,
    Packet.ArtTimeSync,
    Packet.ArtTrigger,
    Packet.ArtDirectory,
    Packet.ArtDirectoryReply,
    Packet.ArtVideoSetup,
    Packet.ArtVideoPalette,
    Packet.ArtVideoData,
    Packet.ArtMacMaster,
    Packet.ArtMacSlave,
    Packet.ArtFirmwareMaster,
    Packet.ArtFirmwareReply,
    Packet.ArtFileTnMaster,
    Packet.ArtFileFnMaster,
    Packet.ArtFileFnReply,
    Packet.ArtIpProg,
    Packet.ArtIpProgReply
  ]

  @op_code_config Map.new(@packet_modules, fn packet_module ->
                    Code.ensure_compiled!(packet_module)
                    {name, code} = packet_module.__op_code__()
                    {name, {code, packet_module}}
                  end)

  # Define the op codes as atoms
  @op_codes Map.keys(@op_code_config)

  @typedoc """
  Supported Art-Net OpCode atoms.
  """
  @type type :: unquote(ArtNet.Packet.Schema.Types.type_ast(@op_codes))

  @doc """
  Returns the Packet module for the given op code.

  If the op code is not supported, nil is returned.
  """
  @spec packet_module_from_value(pos_integer) :: module | nil
  for {_name, {code, packet_module}} <- @op_code_config do
    def packet_module_from_value(unquote(code)), do: unquote(packet_module)
  end

  def packet_module_from_value(_), do: nil

  @doc """
  Returns the OpCode atom for the given integer code.

  If the op code is not supported, nil is returned.
  """
  @spec op_code_type(pos_integer) :: type | nil
  for {name, {code, _}} <- @op_code_config do
    def op_code_type(unquote(code)), do: unquote(name)
  end

  def op_code_type(_), do: nil

  @doc """
  Returns the integer OpCode for a supported OpCode atom or packet module.
  """
  @spec op_code(type | module) :: pos_integer
  for {name, {code, packet_module}} <- @op_code_config do
    def op_code(unquote(packet_module)), do: unquote(code)
    def op_code(unquote(name)), do: unquote(code)
  end
end
