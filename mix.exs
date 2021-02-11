defmodule XXHash.Mixfile do
  use Mix.Project

  def project do
    [
      app: :xxhash,
      version: "0.3.1",
      elixir: "~> 1.0",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp description do
    """
    Native Elixir xxHash port.
    """
  end

  def package do
    [
      files: ["lib", "mix.exs", "README.md"],
      contributors: ["Mykola Konyk", "Derek Kraan", "Christian Green"],
      maintainers: ["Mykola Konyk", "Derek Kraan"],
      licenses: ["MS-RL"],
      links: %{"GitHub" => "https://github.com/ttvd/elixir-xxhash"}
    ]
  end
end
