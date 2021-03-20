defmodule GoldRush.MixProject do
  use Mix.Project

  def project do
    [
      app: :gold_rush,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {GoldRush.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.8"},
      {:uuid, "~> 1.1"},
      {:conqueuer, "~> 0.5.1"}
    ]
  end
end
