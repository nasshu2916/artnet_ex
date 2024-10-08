defmodule ArtNet.Packet.Schema do
  @struct_accumulate_attrs [
    :artnet_fields,
    :artnet_enforce_keys,
    :artnet_types,
    :artnet_reversed_schema
  ]

  @callback validate(packet :: struct) :: :ok | {:error, String.t()}

  @type format ::
          :uint8
          | :uint16
          | {:integer, pos_integer, :little_endian}
          | {:binary, pos_integer}
          | {:string, pos_integer}
          | {:enum_table, module()}
          | {:bit_field, module()}
          | [format()]

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

  Inside a `defpacket` block, each field is defined through the `field/3`
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
    enforce? = has_default?

    Module.put_attribute(module, :artnet_fields, {name, default})
    Module.put_attribute(module, :artnet_types, {name, type_for(format)})
    if enforce?, do: Module.put_attribute(module, :artnet_enforce_keys, name)

    Module.put_attribute(module, :artnet_reversed_schema, {name, {format, opts}})
  end

  defp type_for([format]), do: [type_for(format)]
  defp type_for({:integer, _size}), do: :integer
  defp type_for({:integer, _size, :little_endian}), do: :integer
  defp type_for({:binary, _size}), do: :binary
  defp type_for({:string, _size}), do: {{:., [], [{:__aliases__, [], [:String]}, :t]}, [], []}

  defp type_for({:enum_table, enum_module}),
    do: {{:., [], [{:__aliases__, [], [enum_module]}, :type]}, [], []}

  defp type_for({:bit_field, bit_field_module}),
    do: {{:., [], [{:__aliases__, [], [bit_field_module]}, :t]}, [], []}
end
