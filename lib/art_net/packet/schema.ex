defmodule ArtNet.Packet.Schema do
  @moduledoc """
  This module provides the schema for Art-Net packets.

  The schema is used to define the structure of Art-Net packets.
  """

  @identifier ArtNet.Packet.identifier()
  @version ArtNet.Packet.version()

  defmacro __using__(_opts \\ []) do
    quote do
      import ArtNet.Packet.Schema, only: [defpacket: 1]
    end
  end

  defmacro defpacket(packet_schema) do
    header_schema = [
      id: {:binary, default: @identifier, size: byte_size(@identifier)},
      op_code: {:integer, size: 16, little_endian: true},
      version: {:integer, default: @version, size: 16}
    ]

    schema = header_schema ++ packet_schema

    struct =
      Enum.map(schema, fn {key, {_type, field_opts}} ->
        {key, Keyword.get(field_opts, :default)}
      end)

    types = Enum.map(schema, fn {key, {type, _}} -> {key, type} end)

    quote do
      # @derive {Inspect, except: [:id, :op_code, :version]}
      defstruct unquote(struct)

      @type t :: %__MODULE__{unquote_splicing(types)}

      def schema, do: unquote(schema)

      @spec parse(binary) :: {:ok, t()} | :error
      def parse(packet) do
        ArtNet.Packet.parse(__MODULE__, packet)
      end
    end
  end
end
