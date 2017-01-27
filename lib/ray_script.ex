defmodule RayScript do

  def compile(opts \\ [input_path: Mix.Project.build_path()]) do
    get_modules(opts[:input_path])
    |> Flow.from_enumerable()
    |> Flow.map(&to_abstract(&1))
    |> Flow.map(&to_js(&1))
    |> Flow.each(&to_output(&1))
    |> Enum.to_list
  end

  def get_modules(build_path) do
    Path.join([build_path, "**", "*.beam"])
    |> Path.wildcard
  end

  def to_abstract(beam_path) do
    beam_path = String.to_char_list(beam_path)
    {:ok, {_, [abstract_code: {_, abstract_code}]}} = :beam_lib.chunks(beam_path, [:abstract_code])

    abstract_code
  end

  def to_js(abstract_code) do
    abstract_code
  end

  def to_output(js_code) do
    js_code
  end
end
