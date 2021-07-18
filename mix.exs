defmodule XlsxParser.MixProject do
  use Mix.Project

  def project do
    [
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true,
        plt_file: {:no_warn, "priv/plts/xlsx_parser.plt"}
      ],
      app: :xlsx_parser,
      version: "0.1.2",
      elixir: "~> 1.7",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [main: "XlsxParser", extras: ["README.md"]],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      aliases: aliases()
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
      {:git_hooks, "~> 0.5", only: :dev, runtime: false},
      {:sweet_xml, "~> 0.6"},
      {:simple_agent, "~> 0.0.7", only: :test},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4.10", only: :dev},
      {:ex_doc, "~> 0.22", only: :dev},
      {:ex_unit_notifier, "~> 0.1.4", only: :test},
      {:mix_test_watch, "~> 1.0.2", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13", only: :test},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    "Simple parsing of xlsx spreadsheet data. Data can be retrieved or written to csv."
  end

  defp package do
    [
      maintainers: ["Mike Binns"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/TheFirstAvenger/elixir-xlsx_parser.git"}
    ]
  end

  defp aliases do
    [
      compile: ["compile --warnings-as-errors"]
    ]
  end
end
