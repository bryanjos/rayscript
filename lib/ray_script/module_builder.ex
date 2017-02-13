defmodule RayScript.ModuleBuilder do
  @moduledoc """
  Turns a module in Erlang Abstract Format to a RayScript.Module
  """

  alias ESTree.Tools.Builder, as: J
  alias RayScript.Translator

  @doc """
  Makes a RayScript.Module from the given Erlang Abstract Format Module Declaration
  """
  @spec build(list(tuple)) :: RayScript.Module.t
  def build(abstract) do
    Enum.reduce(abstract, %RayScript.Module{}, fn(ast, result) ->
      process_form(ast, result)
    end)
  end

  @doc """
  Turns a RayScript.Module into a JavaScript Program Node
  """
  @spec to_js_module(RayScript.Module.t) :: ESTree.Program.t
  def to_js_module(result) do
    js_exports = result.export
    |> Enum.reduce([], fn({name, arity}, acc) ->
      acc ++ ["#{name}_#{arity}"]
    end)
    |> Enum.map(fn(name) ->
      J.property(J.identifier(name), J.identifier(name), :init, true)
    end)
    |> J.object_expression
    |> J.export_default_declaration

    js_body = result.body

    J.program(js_body ++ [js_exports], :module)
  end

  defp process_form({:attribute, _, :module, module}, result) do
    %{result | module: module}
  end

  defp process_form({:attribute, _, :file, {file, _}}, result) do
    %{result | file: to_string(file)}
  end

  defp process_form({:attribute, _, :export, exports}, result) do
    %{result | export: exports}
  end

  defp process_form({:function, _, name, arity, clauses}, result) do
    body = Translator.process({:clauses, clauses})

    declarator = J.variable_declarator(
      J.identifier("#{name}_#{arity}"),
      body
    )

    form = J.variable_declaration([declarator], :const)

    %{result | body: result.body ++ [form]}
  end

  defp process_form(_, result) do
    result
  end

end
