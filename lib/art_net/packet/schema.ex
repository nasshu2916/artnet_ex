defmodule ArtNet.Packet.Schema do
  alias ArtNet.Packet.Schema.{CodeGenerator, Types}

  @type format ::
          {:integer, pos_integer}
          | {:integer, pos_integer, :little_endian}
          | {:binary, pos_integer}
          | {:string, pos_integer}
          | {:enum_table, module()}
          | {:bit_field, module()}
          | [format()]

  @type bit_field_format :: :boolean | {:enum_table, module()}

  @struct_accumulate_attrs [
    :artnet_fields,
    :artnet_enforce_keys,
    :artnet_types,
    :artnet_reversed_schema
  ]

  @callback validate(packet :: struct) :: :ok | {:error, String.t()}
  @callback validate_decode(packet :: struct) :: :ok | {:error, String.t()}
  @callback validate_encode(packet :: struct) :: :ok | {:error, String.t()}
  @callback pre_decode(body :: binary) :: binary

  @optional_callbacks pre_decode: 1

  @doc false
  @spec __new__(module, map | Keyword.t()) :: {:ok, struct} | {:error, ArtNet.EncodeError.t()}
  def __new__(module, attrs) when is_map(attrs) or is_list(attrs) do
    build_validated_struct(module, attrs)
  end

  def __new__(_module, _attrs), do: invalid_attrs_error()

  @doc false
  @spec __new__!(module, map | Keyword.t()) :: struct
  def __new__!(module, attrs) do
    case __new__(module, attrs) do
      {:ok, packet} -> packet
      {:error, %ArtNet.EncodeError{} = error} -> raise error
    end
  end

  defp build_validated_struct(module, attrs) do
    with {:ok, packet} <- build_struct(module, attrs),
         :ok <- module.validate_encode(packet) do
      {:ok, packet}
    else
      {:error, %ArtNet.EncodeError{} = error} ->
        {:error, error}

      {:error, reason} when is_binary(reason) ->
        {:error, invalid_data_error(reason)}

      {:error, reason} ->
        {:error, invalid_data_error(inspect(reason))}
    end
  end

  defp build_struct(module, attrs) do
    {:ok, struct!(module, attrs)}
  rescue
    error in [ArgumentError, KeyError] ->
      {:error, invalid_data_error(Exception.message(error))}

    FunctionClauseError ->
      invalid_attrs_error()
  end

  defp invalid_attrs_error do
    {:error, invalid_data_error("attributes must be a map or keyword list")}
  end

  defp invalid_data_error(reason) do
    %ArtNet.EncodeError{reason: {:invalid_data, reason}}
  end

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour ArtNet.Packet.Schema
      @before_compile ArtNet.Packet.Schema

      import ArtNet.Packet.Schema, only: [defpacket: 1, defpacket: 2]

      @impl ArtNet.Packet.Schema
      def validate(_) do
        :ok
      end

      @impl ArtNet.Packet.Schema
      def validate_decode(packet) do
        validate(packet)
      end

      @impl ArtNet.Packet.Schema
      def validate_encode(packet) do
        validate(packet)
      end

      defoverridable validate: 1, validate_decode: 1, validate_encode: 1
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    schema =
      env.module
      |> Module.get_attribute(:artnet_reversed_schema)
      |> Enum.reverse()

    pre_decode_defined? = Module.defines?(env.module, {:pre_decode, 1})

    CodeGenerator.generate(schema, pre_decode_defined?: pre_decode_defined?)
  end

  @doc """
  Defines a typed struct.

  Inside a `defpacket` block, each field is defined through the `field/3`
  macro.
  """
  defmacro defpacket(opts \\ [], do: block) do
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

      def op_code do
        ArtNet.OpCode.op_code(__MODULE__)
      end

      @spec new(map() | Keyword.t()) :: {:ok, t()} | {:error, ArtNet.EncodeError.t()}
      def new(attrs) do
        ArtNet.Packet.Schema.__new__(__MODULE__, attrs)
      end

      @spec new!(map() | Keyword.t()) :: t()
      def new!(attrs) do
        ArtNet.Packet.Schema.__new__!(__MODULE__, attrs)
      end

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
    * `length` - the length of the field
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
    enforce? = not has_default?

    Module.put_attribute(module, :artnet_fields, {name, default})
    Module.put_attribute(module, :artnet_types, {name, Types.type_for(format)})

    if enforce?, do: Module.put_attribute(module, :artnet_enforce_keys, name)

    Module.put_attribute(module, :artnet_reversed_schema, {name, {format, opts}})
  end
end
