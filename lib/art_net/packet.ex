defmodule ArtNet.Packet do
  @identifier "Art-Net" <> <<0>>
  @version 0x14

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
end
