defmodule Altabarra.MixProject do
  use Mix.Project

  def project do
    [
      app: :altabarra,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Altabarra.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Phoenix and web-related
      {:bandit, "~> 1.6"},
      {:corsica, "~> 2.1"},
      {:phoenix, "~> 1.7.18"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_dashboard, "~> 0.8.5"},
      {:phoenix_live_reload, "~> 1.5.3", only: :dev},
      {:phoenix_live_view, "~> 1.0.1"},

      # Database and Ecto
      {:dns_cluster, "~> 0.1.3"},
      {:ecto_sql, "~> 3.12"},
      {:phoenix_ecto, "~> 4.6"},
      {:postgrex, ">= 0.0.0"},

      # Authentication
      {:bcrypt_elixir, "~> 3.2"},

      # Asset compilation
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},

      # HTTP client and API-related
      {:finch, "~> 0.19"},
      {:tesla, "~> 1.13"},

      # Utilities and helpers
      {:floki, "~> 0.37", only: :test},
      {:gettext, "~> 0.26"},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:jason, "~> 1.4"},
      {:swoosh, "~> 1.17"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:stac_validator, "~> 0.1", only: [:dev, :test]},
      {:memoize, "~> 1.4"},

      # Testing
      {:mix_test_watch, "~> 1.2", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.8.0", only: :test},
      {:exvcr, "~> 0.15", only: :test},

      # Telemetry and monitoring
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.1"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind altabarra", "esbuild altabarra"],
      "assets.deploy": [
        "tailwind altabarra --minify",
        "esbuild altabarra --minify",
        "phx.digest"
      ]
    ]
  end
end
