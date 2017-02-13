defmodule RayScript do
  @moduledoc """
  Top-level module for compiling Beam files
  """

  alias RayScript.ModuleBuilder
  alias ESTree.Tools.Generator

  @spec compile(keyword) :: list
  def compile(opts \\ [input_path: Mix.Project.build_path()]) do
    opts[:input_path]
    |> get_modules
    |> Flow.from_enumerable()
    |> Flow.map(&get_beam(&1))
    |> Flow.map(&to_abstract(&1))
    |> Flow.map(&to_js_ast(&1))
    |> Flow.map(&to_js_code(&1))
    |> Flow.map(&to_output(&1))
    |> Enum.to_list
  end

  defp get_modules(build_path) do
    [build_path, "**", "*.beam"]
    |> Path.join
    |> Path.wildcard
  end

  @spec compile_module(binary | atom) :: tuple
  def compile_module(beam) do
    beam
    |> get_beam
    |> to_abstract
    |> to_js_ast
    |> to_js_code
    |> to_output
  end

  defp get_beam(beam) when is_binary(beam) do
    String.to_char_list(beam)
  end

  defp get_beam(beam) when is_atom(beam) do
    {_, beam, _} = :code.get_object_code(beam)
    beam
  end

  defp to_abstract(beam) do
    {:ok, {_, [abstract_code: {_, abstract_code}]}} = :beam_lib.chunks(beam, [:abstract_code])
    abstract_code
  end

  defp to_js_ast(abstract_code) do
    abstract_code
    |> ModuleBuilder.build
    |> ModuleBuilder.to_js_module
  end

  defp to_js_code(js_ast) do
    Generator.generate(js_ast)
  end

  defp to_output(js_code) do
    js_code
  end
end
