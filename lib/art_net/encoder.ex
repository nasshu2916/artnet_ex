defmodule ArtNet.Encoder do
  def encode(value, :uint8, opts) when 0 <= value and value <= 0xFF do
    case Keyword.fetch!(opts, :byte_order) do
      :big -> {:ok, <<value::size(8)>>}
      :little -> {:ok, <<value::little-size(8)>>}
    end
  end

  def encode(value, :uint16, opts) when 0 <= value and value <= 0xFFFF do
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
