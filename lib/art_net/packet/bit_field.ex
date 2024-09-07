defmodule ArtNet.Packet.BitField do
  import Bitwise

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

      offset = Keyword.get(unquote(opts), :offset, 0)
      @artnet_bit_field_offset offset

      import ArtNet.Packet.BitField

      unquote(block)

      @enforce_keys @artnet_enforce_keys
      defstruct Enum.reverse(@artnet_fields)

      ArtNet.Packet.BitField.__struct_type__(@artnet_types)

      @schema Enum.reverse(@artnet_schema)
      def bit_field_schema, do: @schema

      @bit_size Keyword.fetch!(unquote(opts), :size)
      def bit_size, do: @bit_size

      @offset offset
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

    offset = Module.get_attribute(module, :artnet_bit_field_offset)

    size =
      case format do
        :boolean -> 1
      end

    Module.put_attribute(module, :artnet_bit_field_offset, offset + size)

    Module.put_attribute(module, :artnet_fields, {name, default})
    Module.put_attribute(module, :artnet_types, {name, type_for(format)})
    if enforce?, do: Module.put_attribute(module, :artnet_enforce_keys, name)

    Module.put_attribute(module, :artnet_schema, {name, {format, {offset, size}}})
  end

  defp type_for(:boolean), do: :boolean

  @doc """
  Extracts bits from a value.

  ### Examples

    iex> ArtNet.Packet.BitField.extract_bits(0b0110, 0, 2)
    0b10

    iex> ArtNet.Packet.BitField.extract_bits(0b0110, 2, 2)
    0b01

    iex> ArtNet.Packet.BitField.extract_bits(0b0110, 2, 4)
    0b0001
  """
  @spec extract_bits(integer, non_neg_integer, pos_integer) :: non_neg_integer
  def extract_bits(value, offset, length) do
    mask = (1 <<< length) - 1
    value >>> offset &&& mask
  end
end
