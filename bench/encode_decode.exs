defmodule ArtNet.Bench.EncodeDecode do
  alias ArtNet.Packet
  alias ArtNet.Packet.BitField.TalkToMe

  def run do
    Benchee.run(
      %{
        "encode" => fn %{packet: packet} -> ArtNet.encode(packet) end,
        "decode" => fn %{binary: binary} -> ArtNet.decode(binary) end
      },
      inputs: inputs(),
      time: seconds_env("BENCH_TIME", 5),
      warmup: seconds_env("BENCH_WARMUP", 2),
      memory_time: seconds_env("BENCH_MEMORY_TIME", 2),
      pre_check: true
    )
  end

  defp inputs do
    %{
      "ArtPoll" => benchmark_input(art_poll()),
      "ArtDmx 1 slot" => benchmark_input(art_dmx(1)),
      "ArtDmx 64 slots" => benchmark_input(art_dmx(64)),
      "ArtDmx 512 slots" => benchmark_input(art_dmx(512))
    }
  end

  defp benchmark_input(packet) do
    %{packet: packet, binary: ArtNet.encode!(packet)}
  end

  defp art_poll do
    %Packet.ArtPoll{
      talk_to_me: %TalkToMe{
        reply_on_change: true,
        diagnostics: true,
        diag_unicast: true,
        vlc: false,
        targeted_mode: true
      },
      priority: :dp_high,
      target_port_address_top: 0x7FFF,
      target_port_address_bottom: 0x1234,
      esta_manufacturer: 0x414C,
      oem: 0x1234
    }
  end

  defp art_dmx(length) do
    %Packet.ArtDmx{
      sequence: 1,
      physical: 0,
      sub_universe: 0,
      net: 0,
      length: length,
      data: dmx_data(length)
    }
  end

  defp dmx_data(length) do
    Enum.map(0..(length - 1), &rem(&1, 256))
  end

  defp seconds_env(key, default) do
    case System.get_env(key) do
      nil -> default
      value -> String.to_integer(value)
    end
  end
end

ArtNet.Bench.EncodeDecode.run()
