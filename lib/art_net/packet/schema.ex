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
      id: {:binary, default: @art_net_identifier},
      op_code: :integer,
      version: {:integer, default: @packet_version}
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
      @derive {Inspect, except: [:id, :op_code, :version]}
      defstruct unquote(struct)
    end
  end

  @doc ~S"""
  Returns the Art-Net identifier.
  """
  def art_net_identifier, do: @art_net_identifier
end
