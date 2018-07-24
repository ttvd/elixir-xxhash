defmodule XXHash.Mixfile do
  use Mix.Project

  def project do
    [
      app: :xxhash,
      version: "0.2.0",
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
    []
  end

  defp description do
    """
    Native Elixir xxHash port.
    """
  end

  def package do
      [
        files: ["lib", "mix.exs", "README.md"],
        contributors: ["Mykola Konyk"],
        maintainers: ["Mykola Konyk"],
        licenses: ["MS-RL"],
        links: %{"GitHub" => "https://github.com/ttvd/elixir-xxhash"}
      ]
  end
end
