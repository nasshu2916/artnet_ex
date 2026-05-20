defmodule ArtNet.Packet.Schema do
  @moduledoc """
  DSL for defining Art-Net packet structs.

  `ArtNet.Packet.Schema` turns a packet declaration into a typed struct and the
  functions used by `ArtNet.Packet` to encode and decode packet payloads. A
  packet module normally calls `use ArtNet.Packet.Schema` and then defines its
  payload layout inside a `defpacket/2` block.

  ```elixir
  defmodule ArtNet.Packet.ArtPoll do
    use ArtNet.Packet.Schema

    alias ArtNet.Packet.{BitField, EnumTable}

    defpacket do
      field(:talk_to_me, {:bit_field, BitField.TalkToMe})
      field(:priority, {:enum_table, EnumTable.Priority}, default: :dp_all)
      field(:target_port_address_top, {:integer, 16}, default: 0)
      field(:target_port_address_bottom, {:integer, 16}, default: 0)
    end
  end
  ```

  Fields are decoded and encoded in declaration order. Fields without a
  `:default` option become enforced struct keys, while fields with `:default`
  are optional when constructing the packet.

  ## Generated API

  A packet module that uses `defpacket/2` receives:

    * `schema/0` - returns the internal field schema in declaration order.
    * `op_code/0` - returns the Art-Net OpCode registered for the packet
      module.
    * `new/1` and `new!/1` - build validated packet structs from a map or
      keyword list.
    * `require_version_header?/0` - reports whether the protocol version
      header is expected before this packet's payload.
    * `decode/1` and `encode/1` - delegate payload decoding and encoding to
      `ArtNet.Packet`.

  ## Field formats

    * `{:integer, bit_size}` - unsigned big-endian integer.
    * `{:integer, bit_size, :little_endian}` - unsigned little-endian integer.
    * `{:binary, byte_size}` - fixed-size binary. Use `nil` to consume the
      remaining payload when decoding.
    * `{:string, byte_size}` - fixed-size null-padded string. Use `nil` to
      consume the remaining payload when decoding.
    * `{:enum_table, module}` - an atom backed by an
      `ArtNet.Packet.EnumTable` module.
    * `{:bit_field, module}` - a struct backed by an
      `ArtNet.Packet.BitField` module.
    * `[format]` - a list of values encoded with the nested format.

  ## Field options

    * `:default` - value used in the generated struct when the caller does not
      provide the field.
    * `:length` - exact number of items for list fields. Decode reads that many
      items and leaves the rest of the payload for following fields. Encode
      fails when the list length differs.

  ## Packet validation

  Packet modules may override `validate/1`, `validate_decode/1`, or
  `validate_encode/1`. `validate/1` is the shared default for both decode and
  encode validation. Return `:ok` for valid packets or `{:error, reason}` for
  invalid packets.

  Packet modules may also implement `pre_decode/1` when a payload needs to be
  normalized before field decoding. If omitted, the payload is decoded as-is.
  """

  alias ArtNet.Packet.Schema.{CodeGenerator, Types}

  @typedoc """
  Format used by `field/3` in packet schemas.
  """
  @type format ::
          {:integer, pos_integer}
          | {:integer, pos_integer, :little_endian}
          | {:binary, pos_integer | nil}
          | {:string, pos_integer | nil}
          | {:enum_table, module()}
          | {:bit_field, module()}
          | [format()]

  @typedoc """
  Format used by `ArtNet.Packet.BitField.field/3`.
  """
  @type bit_field_format :: :boolean | {:enum_table, module()}

  @struct_accumulate_attrs [
    :artnet_fields,
    :artnet_enforce_keys,
    :artnet_types,
    :artnet_reversed_schema
  ]

  @doc """
  Validates a packet for both decode and encode paths.

  `use ArtNet.Packet.Schema` provides a default implementation that returns
  `:ok`. Override this callback when the same rule applies to decoded packets
  and packets constructed for encoding.
  """
  @callback validate(packet :: struct) :: :ok | {:error, String.t()}

  @doc """
  Validates a decoded packet before it is returned to the caller.
  """
  @callback validate_decode(packet :: struct) :: :ok | {:error, String.t()}

  @doc """
  Validates a packet before it is encoded or returned from `new/1`.
  """
  @callback validate_encode(packet :: struct) :: :ok | {:error, String.t()}

  @doc """
  Normalizes a payload before schema-driven field decoding starts.
  """
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
  Defines a packet schema and generates its typed struct.

  Inside a `defpacket` block, each field is defined through the `field/3`
  macro.

  ## Options

    * `:require_version_header?` - controls whether `ArtNet.Packet` expects the
      protocol version header before this packet's payload. Defaults to `true`.
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
      moduledoc =
        ArtNet.Packet.Schema.__moduledoc_with_layout__(
          Module.get_attribute(__MODULE__, :moduledoc),
          @artnet_schema,
          Enum.reverse(@artnet_fields),
          @artnet_enforce_keys,
          @require_version_header?
        )

      Module.put_attribute(__MODULE__, :moduledoc, {__ENV__.line, moduledoc})

      @doc ArtNet.Packet.Schema.__schema_doc__(
             @artnet_schema,
             Enum.reverse(@artnet_fields),
             @artnet_enforce_keys,
             @require_version_header?
           )
      def schema, do: @artnet_schema

      @doc """
      Returns the Art-Net OpCode value for this packet module.
      """
      @spec op_code :: pos_integer
      def op_code do
        ArtNet.OpCode.op_code(__MODULE__)
      end

      @doc """
      Builds a validated packet struct from a map or keyword list.
      """
      @spec new(map() | Keyword.t()) :: {:ok, t()} | {:error, ArtNet.EncodeError.t()}
      def new(attrs) do
        ArtNet.Packet.Schema.__new__(__MODULE__, attrs)
      end

      @doc """
      Builds a validated packet struct from a map or keyword list.

      Raises `ArtNet.EncodeError` when validation fails.
      """
      @spec new!(map() | Keyword.t()) :: t()
      def new!(attrs) do
        ArtNet.Packet.Schema.__new__!(__MODULE__, attrs)
      end

      @doc """
      Returns whether this packet includes the Art-Net protocol version header.
      """
      @spec require_version_header? :: boolean
      def require_version_header?, do: @require_version_header?

      @doc """
      Decodes a complete Art-Net binary as this packet type.
      """
      @spec decode(binary) :: {:ok, t()} | :error
      def decode(data) do
        ArtNet.Packet.decode(__MODULE__, data)
      end

      @doc """
      Encodes this packet struct into a complete Art-Net binary.
      """
      @spec encode(t()) :: {:ok, binary} | :error
      def encode(%__MODULE__{} = packet) do
        ArtNet.Packet.encode(packet)
      end

      def encode(_) do
        :error
      end
    end
  end

  @doc false
  @spec __schema_doc__([{atom, {format(), Keyword.t()}}], Keyword.t(), [atom], boolean) ::
          String.t()
  def __schema_doc__(schema, fields, enforce_keys, require_version_header?) do
    """
    Returns the packet payload schema in declaration order.

    ## Packet layout

    #{packet_layout_table(schema, fields, enforce_keys, require_version_header?)}
    """
  end

  @doc false
  @spec __moduledoc_with_layout__(
          false | nil | String.t() | {non_neg_integer, String.t()},
          [{atom, {format(), Keyword.t()}}],
          Keyword.t(),
          [atom],
          boolean
        ) :: false | String.t()
  def __moduledoc_with_layout__(false, _schema, _fields, _enforce_keys, _require_version_header?),
    do: false

  def __moduledoc_with_layout__(moduledoc, schema, fields, enforce_keys, require_version_header?) do
    layout = """
    ## Packet layout

    #{packet_layout_table(schema, fields, enforce_keys, require_version_header?)}
    """

    moduledoc
    |> moduledoc_text()
    |> append_doc_section(layout)
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
  Defines a field in a packet schema.

  The field order is the binary payload order. The `format` argument controls
  how the field is decoded and encoded, and `opts` may provide a default value
  or list length.

  ## Options

    * `:default` - default struct value. Without this option, the field is an
      enforced key.
    * `:length` - exact item count for list formats.
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

  defp packet_layout_table(schema, fields, enforce_keys, require_version_header?) do
    header_rows =
      [
        ["Header", "`id`", "8 bytes", "`\"Art-Net\\\\0\"`", "fixed"],
        ["Header", "`op_code`", "2 bytes", "little-endian OpCode", "`op_code/0`"]
      ] ++ version_header_rows(require_version_header?)

    payload_rows =
      Enum.map(schema, fn {name, {format, opts}} ->
        [
          "Payload",
          "`#{name}`",
          size_description(format, opts),
          format_description(format),
          default_description(name, fields, enforce_keys)
        ]
      end)

    markdown_table(["Part", "Field", "Size", "Format", "Default"], header_rows ++ payload_rows)
  end

  defp version_header_rows(true),
    do: [["Header", "`prot_ver`", "2 bytes", "protocol version", "`14`"]]

  defp version_header_rows(false), do: []

  defp size_description([format], opts) do
    length = Keyword.get(opts, :length)
    element_size = size_description(format, [])

    case {length, fixed_size(format)} do
      {nil, _} -> "variable"
      {length, {:bytes, bytes}} -> "#{length * bytes} bytes"
      {length, {:bits, bits}} -> "#{length * bits} bits"
      {length, :variable} -> "#{length} values"
    end
    |> then(fn size -> "#{size} (#{element_size} each)" end)
  end

  defp size_description(format, _opts) do
    case fixed_size(format) do
      {:bytes, 1} -> "1 byte"
      {:bytes, bytes} -> "#{bytes} bytes"
      {:bits, 1} -> "1 bit"
      {:bits, bits} -> "#{bits} bits"
      :variable -> "variable"
    end
  end

  defp fixed_size({:integer, bits}) when rem(bits, 8) == 0, do: {:bytes, div(bits, 8)}
  defp fixed_size({:integer, bits}), do: {:bits, bits}

  defp fixed_size({:integer, bits, :little_endian}) when rem(bits, 8) == 0,
    do: {:bytes, div(bits, 8)}

  defp fixed_size({:integer, bits, :little_endian}), do: {:bits, bits}
  defp fixed_size({:binary, nil}), do: :variable
  defp fixed_size({:binary, bytes}), do: {:bytes, bytes}
  defp fixed_size({:string, nil}), do: :variable
  defp fixed_size({:string, bytes}), do: {:bytes, bytes}
  defp fixed_size({:enum_table, enum_module}), do: bit_or_byte_size(enum_module.bit_size())

  defp fixed_size({:bit_field, bit_field_module}),
    do: bit_or_byte_size(bit_field_module.bit_size())

  defp fixed_size([_format]), do: :variable

  defp bit_or_byte_size(bits) when rem(bits, 8) == 0, do: {:bytes, div(bits, 8)}
  defp bit_or_byte_size(bits), do: {:bits, bits}

  defp format_description([format]), do: "list of #{format_description(format)}"
  defp format_description({:integer, bits}), do: "unsigned integer (#{bits} bits)"

  defp format_description({:integer, bits, :little_endian}),
    do: "little-endian unsigned integer (#{bits} bits)"

  defp format_description({:binary, nil}), do: "binary"
  defp format_description({:binary, bytes}), do: "binary (#{bytes} bytes)"
  defp format_description({:string, nil}), do: "string"
  defp format_description({:string, bytes}), do: "null-padded string (#{bytes} bytes)"
  defp format_description({:enum_table, enum_module}), do: "`#{inspect(enum_module)}` enum"

  defp format_description({:bit_field, bit_field_module}),
    do: "`#{inspect(bit_field_module)}` bit field"

  defp default_description(name, fields, enforce_keys) do
    if name in enforce_keys do
      "required"
    else
      fields
      |> Keyword.fetch!(name)
      |> inspect()
      |> then(&"`#{&1}`")
    end
  end

  defp moduledoc_text(nil), do: ""
  defp moduledoc_text({_line, text}) when is_binary(text), do: text
  defp moduledoc_text(text) when is_binary(text), do: text

  defp append_doc_section(text, section) do
    [String.trim_trailing(text), String.trim_trailing(section)]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n\n")
  end

  defp markdown_table(headers, rows) do
    header = "| #{Enum.join(headers, " | ")} |"
    divider = "| #{Enum.map_join(headers, " | ", fn _ -> "---" end)} |"
    body = Enum.map_join(rows, "\n", fn row -> "| #{Enum.join(row, " | ")} |" end)

    Enum.join([header, divider, body], "\n")
  end
end
