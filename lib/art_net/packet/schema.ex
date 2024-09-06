defmodule ArtNet.Packet.Schema do
  @struct_accumulate_attrs [
    :artnet_fields,
    :artnet_enforce_keys,
    :artnet_types,
    :artnet_reversed_schema
  ]

  @callback validate(packet :: struct) :: :ok | {:error, String.t()}

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour ArtNet.Packet.Schema

      import ArtNet.Packet.Schema, only: [defpacket: 2]

      @impl ArtNet.Packet.Schema
      def validate(_) do
        :ok
      end

      defoverridable validate: 1
    end
  end

  @doc """
  Defines a typed struct.

  Inside a `defpacket` block, each field is defined through the `field/2`
  macro.
  """
  defmacro defpacket(opts, do: block) do
    ArtNet.Packet.Schema.__defpacket__(block, opts)
  end

  @doc false
  def __defpacket__(block, opts) do
    quote do
      Enum.each(unquote(@struct_accumulate_attrs), fn attr ->
        Module.register_attribute(__MODULE__, attr, accumulate: true)
      end)

      import ArtNet.Packet.Schema

      ArtNet.Packet.Schema.__def_header__(unquote(opts))

      unquote(block)

      @enforce_keys @artnet_enforce_keys
      defstruct Enum.reverse(@artnet_fields)

      ArtNet.Packet.Schema.__struct_type__(@artnet_types)

      @artnet_schema Enum.reverse(@artnet_reversed_schema)
      def schema, do: @artnet_schema

      @spec __op_code__ :: pos_integer
      def __op_code__, do: @op_code

      @spec require_version_header? :: boolean
      def require_version_header?, do: @require_version_header?

      @spec decode(binary) :: {:ok, t()} | :error
      def decode(data) do
        ArtNet.Packet.decode(__MODULE__, data)
      end

      @spec encode(t()) :: {:ok, binary} | :error
      def encode(%__MODULE__{} = packet) do
        ArtNet.Packet.encode(packet)
      end

      def encode(_) do
        :error
      end
    end
  end

  defmacro __def_header__(opts) do
    quote bind_quoted: [opts: opts] do
      op_code = Keyword.fetch!(opts, :op_code)
      Module.put_attribute(__MODULE__, :op_code, op_code)

      require_version_header? = Keyword.get(opts, :require_version_header?, true)
      Module.put_attribute(__MODULE__, :require_version_header?, require_version_header?)
    end
  end

  defmacro __struct_type__(types) do
    quote bind_quoted: [types: types] do
      @type t() :: %__MODULE__{unquote_splicing(types)}
    end
  end

  @doc """
  Defines a field in a typed struct.

  options:
    * `default` - the default value for the field, default is nil
    * `nullable` - if true, the field can be nil, default is false
    * `size` - the size of the field in bits, default is nil
  """
  defmacro field(name, format, opts \\ []) do
    quote bind_quoted: [name: name, format: format, opts: opts] do
      ArtNet.Packet.Schema.__field__(name, format, opts, __ENV__)
    end
  end

  @doc false
  def __field__(name, format, opts, env) do
    %Macro.Env{module: module} = env

    unless is_atom(name) do
      raise ArgumentError, "a field name must be an atom, got: #{inspect(name)}"
    end

    if module |> Module.get_attribute(:artnet_fields) |> Keyword.has_key?(name) do
      raise ArgumentError, "the field #{inspect(name)} is already set"
    end

    default = Keyword.get(opts, :default)
    has_default? = Keyword.has_key?(opts, :default)
    nullable? = Keyword.get(opts, :nullable, false)
    enforce? = not (has_default? or nullable?)

    Module.put_attribute(module, :artnet_fields, {name, default})
    Module.put_attribute(module, :artnet_types, {name, type_for(format, nullable?)})
    if enforce?, do: Module.put_attribute(module, :artnet_enforce_keys, name)

    Module.put_attribute(module, :artnet_reversed_schema, {name, {format, opts}})
  end

  defp type_for(format, false), do: format_type(format)
  defp type_for(format, true), do: quote(do: unquote(format_type(format)) | nil)

  defp format_type([format]), do: [format_type(format)]
  defp format_type(format) when format in [:uint8, :uint16], do: :integer
  defp format_type(:binary), do: :binary
  defp format_type(:string), do: {{:., [], [{:__aliases__, [], [:String]}, :t]}, [], []}

  defp format_type({:enum_table, enum_module}),
    do: {{:., [], [{:__aliases__, [], [enum_module]}, :keys]}, [], []}
end
