defmodule ArtNet.Packet.BitField.TalkToMeTest do
  use ExUnit.Case, async: true

  alias ArtNet.Packet.BitField.TalkToMe

  test "decode/encode" do
    [
      {%TalkToMe{
         reply_on_change: false,
         diagnostics: false,
         diag_unicast: false,
         vlc: false
       }, 0b00000000},
      {%TalkToMe{
         reply_on_change: true,
         diagnostics: false,
         diag_unicast: false,
         vlc: true
       }, 0b00010010},
      {%TalkToMe{
         reply_on_change: false,
         diagnostics: true,
         diag_unicast: true,
         vlc: true
       }, 0b00011100}
    ]
    |> Enum.each(fn {bit_field, data} ->
      assert TalkToMe.encode(bit_field) == {:ok, data}
      assert TalkToMe.decode(data) == {:ok, bit_field}
    end)
  end
end
