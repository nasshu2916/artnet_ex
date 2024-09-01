defmodule ArtNet.Packet do
  @identifier "Art-Net" <> <<0>>
  @version 0x14

  def identifier, do: @identifier
  def version, do: @version

  @spec decode(module, binary) :: {:ok, struct} | :error
  def decode(module, packet) do
    module.schema()
    |> Enum.reduce_while({[], packet}, fn {key, {type, opts}}, {values, rest} ->
      case ArtNet.Decoder.decode(rest, type, opts) do
        {:ok, {value, new_rest}} ->
          {:cont, {[{key, value} | values], new_rest}}

        :error ->
          {:halt, :error}
      end
    end)
    |> case do
      :error -> :error
      {data, _rest} -> {:ok, struct!(module, data)}
    end
  end
end
