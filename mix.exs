defmodule RayScript.Mixfile do
  use Mix.Project

  def project do
    [app: :rayscript,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:flow, "~> 0.11.0"},
      {:estree, "~> 2.5"}
    ]
  end
end
