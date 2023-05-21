defmodule ExTypst.MixProject do
  use Mix.Project

  @source_url "https://github.com/viniciusmuller/ex_typst"
  @version "0.1.1"

  def project do
    [
      app: :ex_typst,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "Elixir bindings for the typst typesetting system",
      package: package(),

      # Docs
      name: "ExTypst",
      main: "ExTypst",
      source_url: @source_url
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
      {:rustler, "~> 0.28.0"},
      {:benchee, "~> 1.0", only: :dev},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
    ]
  end

    defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url},
      exclude_patterns: [
        "priv/plts",
        "native/extypst_nif/target",
        "priv/native/libextypst_nif.so"
      ],
      files: [
        "lib",
        "native",
        "priv/native",
        ".formatter.exs",
        "README.md",
        "LICENSE",
        "mix.exs"
      ]
    ]
  end
end
