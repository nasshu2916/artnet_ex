defmodule ArtNet.Packet.BitField do
  import Bitwise

  @struct_accumulate_attrs [
    :artnet_fields,
    :artnet_enforce_keys,
    :artnet_types,
    :artnet_schema
  ]

  @type schema_type :: :boolean | {:enum_table, module}

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

      @artnet_bit_field_offset 0

      import ArtNet.Packet.BitField

      unquote(block)

      @enforce_keys @artnet_enforce_keys
      defstruct Enum.reverse(@artnet_fields)

      ArtNet.Packet.BitField.__struct_type__(@artnet_types)

      @schema Enum.reverse(@artnet_schema)
      @spec bit_field_schema :: [
              {key :: atom,
               {ArtNet.Packet.BitField.schema_type(),
                {start_bit :: non_neg_integer, length :: pos_integer}}}
            ]
      def bit_field_schema, do: @schema

      @bit_size Keyword.fetch!(unquote(opts), :bit_size)
      def bit_size, do: @bit_size

      @spec decode(non_neg_integer) :: {:ok, t()} | :error
      def decode(value), do: ArtNet.Packet.BitField.decode(value, __MODULE__)

      @spec encode(t()) :: {:ok, non_neg_integer} | :error
      def encode(struct), do: ArtNet.Packet.BitField.encode(struct, __MODULE__)
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

    offset =
      Module.get_attribute(module, :artnet_bit_field_offset) + Keyword.get(opts, :offset, 0)

    size =
      case format do
        :boolean -> 1
        {:enum_table, module} -> module.bit_size()
      end

    Module.put_attribute(module, :artnet_bit_field_offset, offset + size)

    Module.put_attribute(module, :artnet_fields, {name, default})
    Module.put_attribute(module, :artnet_types, {name, type_for(format)})
    if enforce?, do: Module.put_attribute(module, :artnet_enforce_keys, name)

    Module.put_attribute(module, :artnet_schema, {name, {format, {offset, size}}})
  end

  defp type_for(:boolean), do: :boolean

  defp type_for({:enum_table, enum_module}),
    do: {{:., [], [{:__aliases__, [], [enum_module]}, :type]}, [], []}

  @spec decode(non_neg_integer, module) :: {:ok, struct} | :error
  def decode(value, module) do
    module.bit_field_schema()
    |> Enum.reduce_while({:ok, []}, fn {key, {type, {offset, length}}}, {:ok, acc} ->
      extracted_value = extract_bits(value, offset, length)

      case cast_value(type, extracted_value) do
        {:ok, result} -> {:cont, {:ok, [{key, result} | acc]}}
        :error -> {:halt, :error}
      end
    end)
    |> case do
      {:ok, params} -> {:ok, struct!(module, params)}
      :error -> :error
    end
  end

  @spec encode(struct, module) :: {:ok, non_neg_integer} | :error
  def encode(struct, module) do
    Enum.reduce_while(module.bit_field_schema(), {:ok, 0}, fn {key, {type, {offset, _}}},
                                                              {:ok, acc} ->
      case dump_value(type, Map.fetch!(struct, key)) do
        {:ok, encode_value} -> {:cont, {:ok, acc + (encode_value <<< offset)}}
        :error -> {:halt, :error}
      end
    end)
  end

  @spec cast_value(schema_type(), non_neg_integer) :: {:ok, any} | :error
  defp cast_value(:boolean, 0), do: {:ok, false}
  defp cast_value(:boolean, 1), do: {:ok, true}
  defp cast_value({:enum_table, enum_module}, value), do: enum_module.to_atom(value)

  @spec dump_value(schema_type(), any) :: {:ok, non_neg_integer} | :error
  defp dump_value(:boolean, false), do: {:ok, 0}
  defp dump_value(:boolean, true), do: {:ok, 1}
  defp dump_value({:enum_table, enum_module}, value), do: enum_module.to_code(value)

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
