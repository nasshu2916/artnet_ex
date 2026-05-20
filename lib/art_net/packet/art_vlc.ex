defmodule ArtNet.Packet.ArtVlc.Flags do
  @moduledoc """
  Decoded VLC flag bits from an `ArtVlc` payload.
  """

  @typedoc """
  VLC flags with the original raw byte retained.
  """
  @type t :: %__MODULE__{
          ieee?: boolean,
          reply?: boolean,
          beacon?: boolean,
          raw: non_neg_integer
        }

  defstruct ieee?: false,
            reply?: false,
            beacon?: false,
            raw: 0
end

defmodule ArtNet.Packet.ArtVlc do
  @moduledoc """
  Decoder for VLC payloads carried by `ArtNet.Packet.ArtNzs`.

  Art-Net VLC data is represented on the wire as an `ArtNzs` packet with start
  code `0x91`. Decode the Art-Net packet first with `ArtNet.decode/1`, or pass
  the complete binary directly to `decode/1`.

  ```elixir
  with {:ok, %ArtNet.Packet.ArtNzs{} = nzs} <- ArtNet.decode(binary),
       {:ok, vlc} <- ArtNet.Packet.ArtVlc.decode(nzs) do
    vlc.payload
  end
  ```

  This module currently provides decoding and checksum helpers for VLC payloads.
  Encoding is handled by building the corresponding `ArtNzs` packet.
  """

  alias ArtNet.Packet.ArtNzs
  alias ArtNet.Packet.ArtVlc.Flags

  import Bitwise

  @start_code 0x91
  @man_id 0x414C
  @sub_code 0x45
  @fixed_data_size 22
  @max_payload_size 480

  @typedoc """
  Structured ArtVlc payload decoded from an `ArtNzs` packet.
  """
  @type t :: %__MODULE__{
          sequence: non_neg_integer,
          sub_universe: non_neg_integer,
          net: non_neg_integer,
          man_id: non_neg_integer,
          sub_code: non_neg_integer,
          flags: Flags.t(),
          transaction: non_neg_integer,
          slot_address: non_neg_integer,
          payload_count: non_neg_integer,
          payload_checksum: non_neg_integer,
          spare: non_neg_integer,
          vlc_depth: non_neg_integer,
          vlc_frequency: non_neg_integer,
          vlc_modulation: non_neg_integer,
          payload_language: non_neg_integer,
          beacon_repeat: non_neg_integer,
          payload: [non_neg_integer]
        }

  defstruct sequence: 0,
            sub_universe: 0,
            net: 0,
            man_id: @man_id,
            sub_code: @sub_code,
            flags: %Flags{},
            transaction: 0,
            slot_address: 0,
            payload_count: 0,
            payload_checksum: 0,
            spare: 0,
            vlc_depth: 0,
            vlc_frequency: 0,
            vlc_modulation: 0,
            payload_language: 0,
            beacon_repeat: 0,
            payload: []

  @doc """
  Decodes an ArtVlc payload from a complete Art-Net binary or an `ArtNzs` packet.

  The function validates the `ArtNzs` start code, fixed VLC magic fields,
  payload length, maximum payload size, and payload checksum.
  """
  @spec decode(binary | ArtNzs.t()) :: {:ok, t()} | {:error, ArtNet.DecodeError.t()}
  def decode(binary) when is_binary(binary) do
    case ArtNet.Packet.decode(binary) do
      {:ok, %ArtNzs{} = packet} -> decode(packet)
      {:ok, _packet} -> invalid_data("ArtVlc must be encoded as ArtNzs")
      {:error, %ArtNet.DecodeError{} = error} -> {:error, error}
    end
  end

  def decode(%ArtNzs{start_code: @start_code, length: length, data: data})
      when length != Kernel.length(data) do
    invalid_data("ArtVlc data length does not match the ArtNzs length field")
  end

  def decode(%ArtNzs{start_code: @start_code, data: data} = packet)
      when length(data) >= @fixed_data_size do
    with {:ok, vlc} <- decode_data(packet, data),
         :ok <- validate_payload(vlc) do
      {:ok, vlc}
    end
  end

  def decode(%ArtNzs{start_code: @start_code}) do
    invalid_data("ArtVlc data is shorter than the fixed VLC header")
  end

  def decode(%ArtNzs{}) do
    invalid_data("ArtVlc start code must be 0x91")
  end

  def decode(_) do
    invalid_data("ArtVlc decode expects an ArtNzs packet or binary")
  end

  @doc """
  Calculates the 16-bit additive checksum for a VLC payload.
  """
  @spec checksum([non_neg_integer]) :: non_neg_integer
  def checksum(payload) when is_list(payload) do
    payload
    |> Enum.reduce(0, fn value, acc -> acc + value end)
    |> band(0xFFFF)
  end

  defp decode_data(packet, [
         0x41,
         0x4C,
         @sub_code,
         flags,
         transaction_hi,
         transaction_lo,
         slot_address_hi,
         slot_address_lo,
         payload_count_hi,
         payload_count_lo,
         payload_checksum_hi,
         payload_checksum_lo,
         spare,
         vlc_depth,
         vlc_frequency_hi,
         vlc_frequency_lo,
         vlc_modulation_hi,
         vlc_modulation_lo,
         payload_language_hi,
         payload_language_lo,
         beacon_repeat_hi,
         beacon_repeat_lo
         | payload
       ]) do
    {:ok,
     %__MODULE__{
       sequence: packet.sequence,
       sub_universe: packet.sub_universe,
       net: packet.net,
       flags: decode_flags(flags),
       transaction: uint16(transaction_hi, transaction_lo),
       slot_address: uint16(slot_address_hi, slot_address_lo),
       payload_count: uint16(payload_count_hi, payload_count_lo),
       payload_checksum: uint16(payload_checksum_hi, payload_checksum_lo),
       spare: spare,
       vlc_depth: vlc_depth,
       vlc_frequency: uint16(vlc_frequency_hi, vlc_frequency_lo),
       vlc_modulation: uint16(vlc_modulation_hi, vlc_modulation_lo),
       payload_language: uint16(payload_language_hi, payload_language_lo),
       beacon_repeat: uint16(beacon_repeat_hi, beacon_repeat_lo),
       payload: payload
     }}
  end

  defp decode_data(_packet, _data) do
    invalid_data("ArtVlc magic fields must be 0x41, 0x4C, 0x45")
  end

  defp validate_payload(%__MODULE__{payload_count: payload_count})
       when payload_count > @max_payload_size do
    invalid_data("ArtVlc payload count must be 480 or less")
  end

  defp validate_payload(%__MODULE__{payload_count: payload_count, payload: payload})
       when payload_count != length(payload) do
    invalid_data("ArtVlc payload count does not match the payload length")
  end

  defp validate_payload(%__MODULE__{payload_checksum: payload_checksum, payload: payload}) do
    if payload_checksum == checksum(payload) do
      :ok
    else
      invalid_data("ArtVlc payload checksum does not match the payload")
    end
  end

  defp decode_flags(value) do
    %Flags{
      ieee?: flag?(value, 7),
      reply?: flag?(value, 6),
      beacon?: flag?(value, 5),
      raw: value
    }
  end

  defp flag?(value, offset), do: (value &&& 1 <<< offset) != 0
  defp uint16(hi, lo), do: hi <<< 8 ||| lo

  defp invalid_data(reason) do
    {:error, %ArtNet.DecodeError{reason: {:invalid_data, reason}}}
  end
end
