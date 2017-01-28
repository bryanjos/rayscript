defmodule RayScript do

  def compile(opts \\ [input_path: Mix.Project.build_path()]) do
    get_modules(opts[:input_path])
    |> Flow.from_enumerable()
    |> Flow.map(&get_beam(&1))
    |> Flow.map(&to_abstract(&1))
    |> Flow.map(&to_js_ast(&1))
    |> Flow.map(&to_js_code(&1))
    |> Flow.map(&to_output(&1))
    |> Enum.to_list
  end

  def compile_module(beam) do
    beam
    |> get_beam
    |> to_abstract
    |> to_core
    |> to_js_ast
    |> to_js_code
    |> to_output
  end

  def get_modules(build_path) do
    Path.join([build_path, "**", "*.beam"])
    |> Path.wildcard
  end

  def get_beam(beam) when is_binary(beam) do
    String.to_char_list(beam)
  end

  def get_beam(beam) when is_atom(beam) do
    {_, beam, _} = :code.get_object_code(beam)
    beam
  end

  def to_abstract(beam) do
    {:ok, {_, [abstract_code: {_, abstract_code}]}} = :beam_lib.chunks(beam, [:abstract_code])
    abstract_code
  end

  def to_core(abstract_code) do
    {:ok, _module, core_code} = :compile.forms(abstract_code, [:to_core])
    core_code
  end

  def to_js_ast(abstract_code) do
    abstract_code
  end

  def to_js_code(js_ast) do
    js_ast
  end

  def to_output(js_code) do
    js_code
  end
end
