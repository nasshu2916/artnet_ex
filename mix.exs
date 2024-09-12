defmodule ArtNet.MixProject do
  use Mix.Project

  def project do
    [
      app: :art_net,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      formatters: ["html"],
      extras: [
        "README.md",
        "livebook/artnet_sample.livemd",
        {:LICENSE, [title: "License (MIT)"]}
      ]
    ]
  end
end
