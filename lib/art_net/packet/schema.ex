defmodule ArtNet.Packet.Schema do
  @struct_accumulate_attrs [
    :artnet_fields,
    :artnet_enforce_keys,
    :artnet_types,
    :artnet_reversed_schema
  ]

  @doc false
  defmacro __using__(_) do
    quote do
      import ArtNet.Packet.Schema, only: [defpacket: 2]
    end
  end

  @doc """
  Defines a typed struct.

  Inside a `defpacket` block, each field is defined through the `field/2`
  macro.
  """
  defmacro defpacket(opts, do: block) do
    ast = ArtNet.Packet.Schema.__defpacket__(block, opts)

    quote do
      (fn -> unquote(ast) end).()
    end
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

      @artnet_schema Enum.reverse(@artnet_reversed_schema)
      def schema, do: @artnet_schema

      def decode(packet) do
        ArtNet.Packet.parse(__MODULE__, packet)
      end

      ArtNet.Packet.Schema.__struct_type__(@artnet_types)
    end
  end

  defmacro __def_header__(opts) do
    quote bind_quoted: [opts: opts] do
      field(:id, :binary, default: ArtNet.Packet.identifier(), size: 8)
      field(:op_code, :integer, default: Keyword.fetch!(opts, :op_code), size: 16)
      field(:version, :integer, default: ArtNet.Packet.version(), size: 16)
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
    * `default` - the default value for the field
    * `nullable` - if true, the field can be nil
  """
  defmacro field(name, type, opts \\ []) do
    quote bind_quoted: [name: name, type: Macro.escape(type), opts: opts] do
      ArtNet.Packet.Schema.__field__(name, type, opts, __ENV__)
    end
  end

  @doc false
  def __field__(name, type, opts, env) do
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

    size = Keyword.get(opts, :size)

    Module.put_attribute(module, :artnet_fields, {name, default})
    Module.put_attribute(module, :artnet_types, {name, type_for(type, nullable?)})
    if enforce?, do: Module.put_attribute(module, :artnet_enforce_keys, name)

    meta = %{
      default: default,
      nullable?: nullable?,
      size: size
    }

    Module.put_attribute(module, :artnet_reversed_schema, {name, {type, meta}})
  end

  defp type_for(type, false), do: type
  defp type_for(type, true), do: quote(do: unquote(type) | nil)
end
