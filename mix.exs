defmodule XlsxParser.Mixfile do
  use Mix.Project

  def project do
    [app: :xlsx_parser,
     version: "0.0.1",
     elixir: "~> 1.0",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     docs: [readme: "README.md",
       main: "README",
       source_url: "https://github.com/TheFirstAvenger/elixir-xlsx_parser.git"]
]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:sweet_xml, "~> 0.4.0"},
     {:simple_agent, "~> 0.0.7"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.7", only: :dev}]
  end


  defp description do
    "Simple parsing of xlsx spreadsheet data. Data can be retrieved or written to csv."
  end

  defp package do
    [contributors: ["Mike Binns"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/TheFirstAvenger/elixir-xlsx_parser.git"}]
  end
end