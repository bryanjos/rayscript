defmodule RayScript.Mixfile do
  use Mix.Project

  def project do
    [app: :rayscript,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     erlc_paths: erlc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],     
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp erlc_paths(:test), do: ["src", "test/support"]
  defp erlc_paths(_),     do: ["src"]

  defp deps do
    [
      {:flow, "~> 0.11.0"},
      {:estree, "~> 2.5"},
      {:excoveralls, "~> 0.6.2", only: :test},
      {:dialyxir, "~> 0.4", only: :dev, runtime: false},
      {:credo, "~> 0.6.1", only: :dev},
      {:ex_doc, "~> 0.14.5", only: :dev}
    ]
  end
end
