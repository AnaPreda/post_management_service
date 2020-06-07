defmodule PostManagementService.MixProject do
  use Mix.Project

  def project do
    [
      app: :post_management_service,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {PostManagementService.Application, []},
      extra_applications: [:logger]
    ]
  end
    defp elixirc_paths(_), do: ["lib"]
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.0", override: true},
      {:phoenix, "~> 1.4.16"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:plug, "~> 1.6"},
      {:cowboy, "~> 2.4"},
      {:plug_cowboy, "~> 2.0"},
      {:timex, "~> 3.0"},
      {:jsonapi, "~> 0.3.0"},
      {:jason, "~> 1.0"},
      {:joken, "~> 1.1", override: true},
      {:ecto_sql, "~> 3.2"},
      {:cors_plug, "~> 1.5"},
      {:postgrex, "~> 0.15"},
      {:httpotion, "~> 3.1.0"},
      {:connection, "~> 1.0"},
      {:blocking_queue, "~> 1.3"}
    ]
  end
    defp aliases do
      [
        "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
        "ecto.reset": ["ecto.drop", "ecto.setup"],
        test: ["ecto.create --quiet", "ecto.migrate", "test"]
      ]
    end
end
