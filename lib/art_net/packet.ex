defmodule ArtNet.Packet do
  @identifier "Art-Net" <> <<0>>
  @version 14

  def identifier, do: @identifier
  def version, do: @version

  @spec decode(module, binary) :: {:ok, struct} | :error
  def decode(module, binary) do
    module.schema()
    |> Enum.reduce_while({[], binary}, fn {key, {type, opts}}, {values, rest} ->
      case ArtNet.Decoder.decode(rest, type, opts) do
        {:ok, {value, rest}} ->
          {:cont, {[{key, value} | values], rest}}

        :error ->
          {:halt, :error}
      end
    end)
    |> case do
      :error -> :error
      {params, _rest} -> {:ok, struct!(module, params)}
    end
  end

  @spec encode(struct) :: {:ok, binary} | :error
  def encode(packet) do
    packet.__struct__.schema()
    |> Enum.reduce_while([], fn {key, {type, opts}}, acc ->
      value = Map.fetch!(packet, key)

      case ArtNet.Encoder.encode(value, type, opts) do
        {:ok, data} -> {:cont, [data | acc]}
        :error -> {:halt, :error}
      end
    end)
    |> case do
      :error -> :error
      data -> {:ok, data |> Enum.reverse() |> IO.iodata_to_binary()}
    end
  end

  @spec validate(struct) :: :ok | {:error, String.t()}
  def validate(packet) do
    module = packet.__struct__

    with :ok <- validate_header(module, packet),
         :ok <- module.validate_body(packet) do
      :ok
    end
  end

  @spec validate_header(module, struct) :: :ok | {:error, String.t()}
  defp validate_header(module, packet) do
    with :ok <- validate_identifier(packet),
         :ok <- validate_op_code(module, packet),
         :ok <- validate_version(module, packet) do
      :ok
    end
  end

  defp validate_identifier(%{id: @identifier}), do: :ok
  defp validate_identifier(_), do: {:error, "Invalid identifier"}

  defp validate_op_code(module, packet) do
    if module.__op_code__() == packet.op_code do
      :ok
    else
      {:error, "Invalid op code"}
    end
  end

  defp validate_version(module, packet) do
    module_version = module.__version__()

    cond do
      is_nil(module_version) -> :ok
      module_version == packet.version -> :ok
      true -> {:error, "Invalid version"}
    end
  end
end
