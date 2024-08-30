defmodule ArtNet.Packet.Schema do
  @moduledoc """
  This module provides the schema for Art-Net packets.

  The schema is used to define the structure of Art-Net packets.
  """

  @art_net_identifier "Art-Net" <> <<0>>
  @packet_version 0x14

  defp fetch_default_value({_type, opts}) do
    Keyword.fetch(opts, :default)
  end

  defp fetch_default_value(_type) do
    :error
  end

  defmacro __using__(_opts \\ []) do
    quote do
      import ArtNet.Packet.Schema, only: [defpacket: 1]
    end
  end

  defmacro defpacket(packet_schema) do
    header_schema = [
      id: {:binary, default: @art_net_identifier, size: byte_size(@art_net_identifier)},
      op_code: {:integer, size: 16, little_endian: true},
      version: {:integer, default: @packet_version, size: 16}
    ]

    schema = header_schema ++ packet_schema

    struct =
      Enum.map(schema, fn {key, key_opts} ->
        case fetch_default_value(key_opts) do
          :error -> key
          {:ok, default} -> {key, default}
        end
      end)

    quote do
      # @derive {Inspect, except: [:id, :op_code, :version]}
      defstruct unquote(struct)

      def schema, do: unquote(schema)

      def parse(packet) do
        ArtNet.Packet.Schema.parse(__MODULE__, packet)
      end
    end
  end

  @doc ~S"""
  Returns the Art-Net identifier.
  """
  @spec art_net_identifier :: binary
  def art_net_identifier, do: @art_net_identifier

  @spec parse(module, binary) :: {:ok, struct} | :error
  def parse(module, packet) do
    module.schema()
    |> Enum.reduce_while({[], packet}, fn {key, key_opts}, {values, rest} ->
      {type, opts} = key_opts
      size = Keyword.get(opts, :size)

      case ArtNet.Decoder.parse(rest, type, size) do
        {:ok, {value, new_rest}} ->
          {:cont, {[{key, value} | values], new_rest}}

        :error ->
          {:halt, :error}
      end
    end)
    |> case do
      {data, ""} -> {:ok, struct!(module, data)}
      _ -> :error
    end
  end
end
