defmodule RayScript.Mixfile do
  use Mix.Project

  def project do
    [app: :ray_script,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:flow, "~> 0.11.0"},
      {:estree, "~> 2.5"}
    ]
  end
end
