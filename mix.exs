defmodule GcNLP.Mixfile do
  use Mix.Project

  def project do
    [app: :gc_nlp,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Elixir wrapper for Google Cloud Natural Language API",
     package: package,
     docs: [extras: ["README.md"]],
     deps: deps()]
  end

  def package do
    [ name: :gc_nlp,
      files: ["lib", "mix.exs"],
      maintainers: ["Teo Choong Ping"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/seymores/gc_nlp"},
    ]
  end

  def application do
    [applications: [:logger, :httpoison, :goth]]
  end

  defp deps do
    [{:httpoison, "~> 0.9.0"},
     {:goth, "~> 0.2.1"},
     {:ex_doc, "~> 0.14", only: :dev},
     {:ex_doc, ">= 1.0.3", only: :dev}]
  end
end
