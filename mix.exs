defmodule GcNLP.Mixfile do
  use Mix.Project

  def project do
    [app: :gc_nlp,
     version: "0.2.2",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Elixir wrapper for Google Cloud Natural Language API",
     package: package(),
     docs: [extras: ["README.md"]],
     deps: deps()]
  end

  defp package do
    [ name: :gc_nlp,
      files: ["lib", "mix.exs"],
      maintainers: ["Teo Choong Ping"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/seymores/gc_nlp"},
    ]
  end

  def application do
    [
      applications: [:logger, :cachex, :httpoison, :goth],
      mod: {GcNLP.Application, []}
    ]
  end

  defp deps do
    [{:httpoison, "~> 0.11"},
     {:cachex, "~> 2.1"},
     {:goth, "~> 0.3.1"},
     {:ex_doc, "~> 0.15", only: :dev, override: true},
     {:earmark, "~> 1.2.0", only: :dev, override: true}]
  end
  
end
