defmodule PostgresDescribe.Mixfile do
  use Mix.Project

  @app :postgres_describe
  @name "PostgresDescribe"
  @version "0.1.4"
  @github "https://github.com/brandonparsons/#{@app}"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.4",
      description: description(),
      package: package(),
      deps: deps(),

      # ExDoc
      name: @name,
      source_url: @github,
      homepage_url: @github,
      docs: [
        main: @name,
        canonical: "https://hexdocs.pm/#{@app}",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp description do
    """
    Library for describing postgres tables and saving that output into a given
    location in your application source.
    """
  end

  defp package do
    [
      name: @app,
      maintainers: ["Brandon Parsons"],
      licenses: ["MIT"],
      files: ["mix.exs", "lib", "README*", "LICENSE*"],
      links: %{"Github" => @github}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:cortex, "~> 0.3", only: [:dev, :test]},
      {:private, "~> 0.1.1"},
      {:temp, "~> 0.4", only: [:test]}
    ]
  end
end
