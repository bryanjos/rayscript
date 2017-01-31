defmodule Mix.Tasks.Compile.RayScript do
  use Mix.Task

  @moduledoc """
  Mix compiler to allow mix to compile Beam files into JavaScript

  Looks for an `rayscript` key in your mix project config

      def project do
      [
        app: :my_app,
        version: "0.1.0",
        elixir: "~> 1.0",
        deps: deps,
        rayscript: rayscript_params,
        compilers: Mix.compilers() ++ [:rayscript]
      ]
      end
  """


  def run(_) do
    RayScript.compile()
    :ok
  end

  def clean do
    :ok
  end

  defp get_config() do
    config  = Mix.Project.config
    Keyword.fetch!(config, :rayscript)
  end

end
