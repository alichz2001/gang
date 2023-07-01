defmodule Gang.MixProject do
  use Mix.Project

  def project do
    [
      app: :gang,
      version: "0.1.0",
      description: "A package developed in Elixir for code organization and preventing code repetition in specific development scenarios.",
      elixir: "~> 1.15",
      source_url: "https://github.com/alichz2001/gang",
      docs: [
        extras: ["README.md"],
        source_ref: "main"
      ],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        credo: :test,
        "coveralls.html": :test,
        commit: :test
      ],
      aliases: [
        commit: ["dialyzer", "credo --strict", "coveralls.html --trace"]
      ],
      default_task: "commit"
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
      {:credo, "~> 1.7.0", only: :test},
      {:excoveralls, "~> 0.16.0", only: :test},
      {:dialyxir, "~> 1.3.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.29.0", only: :dev},
      {:earmark, "~> 1.4.0", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["AliChZ"],
      licenses: ["Apache 2.0"],
      links: %{github: "https://github.com/alichz2001/gang"}
    ]
  end
end
