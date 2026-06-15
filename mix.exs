defmodule ArtNet.MixProject do
  use Mix.Project

  @source_url "https://github.com/nasshu2916/artnet_ex"
  @description "An Elixir library for decoding and encoding Art-Net packets."

  def project do
    [
      app: :art_net,
      version: "0.1.0",
      elixir: "~> 1.15",
      description: @description,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ArtNet",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.3", only: :dev, runtime: false},
      {:ex_doc, "~> 0.40.3", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "livebook/artnet_sample.livemd",
        "livebook/files",
        "mix.exs",
        "README.md",
        "LICENSE"
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Art-Net Specification" =>
          "https://artisticlicence.com/WebSiteMaster/User%20Guides/art-net.pdf"
      }
    ]
  end

  defp docs do
    [
      formatters: ["html"],
      main: "readme",
      source_ref: "main",
      extras: [
        "README.md",
        "livebook/artnet_sample.livemd",
        {:LICENSE, [title: "License (MIT)"]}
      ],
      groups_for_extras: [
        Guides: ["README.md", "livebook/artnet_sample.livemd"],
        Legal: ["LICENSE"]
      ],
      groups_for_modules: [
        "Main API": [
          ArtNet,
          ArtNet.Packet,
          ArtNet.OpCode
        ],
        "Packet Structs": ~r/^ArtNet\.Packet\.Art/,
        "Schema DSL": [
          ArtNet.Packet.Schema,
          ArtNet.Packet.BitField,
          ArtNet.Packet.EnumTable
        ],
        "Bit Fields": ~r/^ArtNet\.Packet\.BitField\./,
        "Enum Tables": ~r/^ArtNet\.Packet\.EnumTable\./,
        "Low-level Codecs": [
          ArtNet.Decoder,
          ArtNet.Encoder
        ],
        Errors: [
          ArtNet.DecodeError,
          ArtNet.EncodeError
        ],
        Utilities: [
          ArtNet.Misc
        ]
      ],
      nest_modules_by_prefix: [
        ArtNet.Packet,
        ArtNet.Packet.BitField,
        ArtNet.Packet.EnumTable
      ],
      before_closing_head_tag: &before_closing_head_tag/1
    ]
  end

  defp before_closing_head_tag(:html) do
    """
    <script>
    (() => {
      let sidebarNodesValue;

      Object.defineProperty(window, "sidebarNodes", {
        configurable: true,
        get() {
          return sidebarNodesValue;
        },
        set(value) {
          for (const moduleNode of value?.modules ?? []) {
            if (moduleNode.nested_title?.startsWith(".")) {
              moduleNode.nested_title = moduleNode.nested_title.slice(1);
            }
          }

          sidebarNodesValue = value;
        }
      });
    })();
    </script>
    """
  end

  defp before_closing_head_tag(_), do: ""
end
