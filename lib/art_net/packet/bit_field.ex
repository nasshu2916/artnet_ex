defmodule ArtNet.Packet.BitField do
  @struct_accumulate_attrs [
    :artnet_fields,
    :artnet_enforce_keys,
    :artnet_types,
    :artnet_schema
  ]

  defmacro __using__(_) do
    quote do
      import ArtNet.Packet.BitField, only: [defbitfield: 2]
    end
  end

  @doc """
  Defines a typed struct.

  Inside a `defpacket` block, each field is defined through the `field/3`
  macro.
  """
  defmacro defbitfield(opts, do: block) do
    ArtNet.Packet.BitField.__defbitfield__(opts, block)
  end

  @doc false
  def __defbitfield__(opts, block) do
    quote do
      Enum.each(unquote(@struct_accumulate_attrs), fn attr ->
        Module.register_attribute(__MODULE__, attr, accumulate: true)
      end)

      import ArtNet.Packet.BitField

      unquote(block)

      @enforce_keys @artnet_enforce_keys
      defstruct Enum.reverse(@artnet_fields)

      ArtNet.Packet.BitField.__struct_type__(@artnet_types)

      @schema Enum.reverse(@artnet_schema)
      def schema, do: @schema

      @bit_size Keyword.fetch!(unquote(opts), :size)
      def bit_size, do: @bit_size

      @offset Keyword.get(unquote(opts), :offset, 0)
      def offset, do: @offset
    end
  end

  defmacro __struct_type__(types) do
    quote bind_quoted: [types: types] do
      @type t() :: %__MODULE__{unquote_splicing(types)}
    end
  end

  defmacro field(name, format, opts \\ []) do
    quote bind_quoted: [name: name, format: format, opts: opts] do
      ArtNet.Packet.BitField.__field__(name, format, opts, __ENV__)
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
    enforce? = not has_default?

    Module.put_attribute(module, :artnet_fields, {name, default})
    Module.put_attribute(module, :artnet_types, {name, type_for(format)})
    if enforce?, do: Module.put_attribute(module, :artnet_enforce_keys, name)

    Module.put_attribute(module, :artnet_schema, {name, {format, opts}})
  end

  defp type_for(:boolean), do: :boolean
end
