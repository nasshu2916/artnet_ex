defmodule ArtNet.Packet do
  @identifier "Art-Net" <> <<0>>
  @version 0x14

  def identifier, do: @identifier
  def version, do: @version

  @spec parse(module, binary) :: {:ok, struct} | :error
  def parse(module, packet) do
    module.schema()
    |> Enum.reduce_while({[], packet}, fn {key, {type, meta}}, {values, rest} ->
      %{size: size} = meta

      case ArtNet.Decoder.parse(rest, type, size) do
        {:ok, {value, new_rest}} ->
          {:cont, {[{key, value} | values], new_rest}}

        :error ->
          {:halt, :error}
      end
    end)
    |> case do
      {data, ""} -> {:ok, struct!(module, data)}
      _ -> :error
    end
  end
end
