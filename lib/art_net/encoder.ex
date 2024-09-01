defmodule ArtNet.Encoder do
  def encode(value, :uint8, opts) when value >= 0 and value <= 0xff do
    case Keyword.fetch!(opts, :byte_order) do
      :big -> {:ok, <<value::size(8)>>}
      :little -> {:ok, <<value::little-size(8)>>}
    end
  end

  def encode(value, :uint16, opts) when value >= 0 and value <= 0xffff do
    case Keyword.fetch!(opts, :byte_order) do
      :big -> {:ok, <<value::size(16)>>}
      :little -> {:ok, <<value::little-size(16)>>}
    end
  end

  def encode(value, :binary, _opts) do
    {:ok, value}
  end

  def encode(_, _, _) do
    :error
  end
end
