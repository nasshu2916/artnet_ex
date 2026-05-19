defmodule ArtNet.Misc do
  @doc """
  Pads a binary with zero bytes to reach the specified length.

  If `min_length` is given, padding is only applied when the binary size
  is at least `min_length`. Otherwise, the binary is returned as-is.

  ## Parameters
    * `binary` - the binary to pad
    * `length` - target size after padding
    * `min_length` - minimum size required to trigger padding (default: `0`)

  ## Examples

      iex> ArtNet.Misc.pad_binary(<<1, 2>>, 5)
      <<1, 2, 0, 0, 0>>

      iex> ArtNet.Misc.pad_binary(<<1, 2, 3, 4, 5>>, 5)
      <<1, 2, 3, 4, 5>>

      iex> ArtNet.Misc.pad_binary(<<1>>, 5, 2)
      <<1>>
  """
  @spec pad_binary(binary, pos_integer, non_neg_integer) :: binary
  def pad_binary(binary, length, min_length \\ 0) do
    byte_size = byte_size(binary)

    if byte_size >= min_length and byte_size < length do
      binary <> :binary.copy(<<0>>, length - byte_size)
    else
      binary
    end
  end
end
