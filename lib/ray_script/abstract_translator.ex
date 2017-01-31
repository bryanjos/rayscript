defmodule RayScript.AbstractTranslator do
  alias ESTree.Tools.Builder, as: J

  def translate(abstract) do
    Enum.reduce(abstract, %RayScript.Result{}, fn(ast, result) ->
      process_form(ast, result)
    end)
    |> build_module
  end

  defp build_module(result) do
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

  defp process_form({:attribute, _, :file, {file, _}}, result) do
    %{ result | file: file }
  end

  defp process_form({:attribute, _, :export, exports}, result) do
    %{ result | export: exports }
  end

  defp process_form({:function, _, name, arity, clauses}, result) do
    body = process_clauses(clauses)

    declarator = J.variable_declarator(
      J.identifier("#{name}_#{arity}"),
      body
    )

    form = J.variable_declaration([declarator], :const)

    %{ result | body: result.body ++ [form] }
  end

  defp process_form(_, result) do
    result
  end

  defp process_clauses(clauses) do
    processed = Enum.map(clauses, &process_clause(&1))

    J.call_expression(
      J.member_expression(
        J.identifier("Patterns"),
        J.identifier("defmatch")
      ),
      processed
    )
  end

  defp process_clause({:clause, _, pattern, guard, body}) do
    J.call_expression(
      J.member_expression(
        J.identifier("Patterns"),
        J.identifier("clause")
      ),
      [
        process_pattern(pattern),
        process_body(body),
        process_guard(guard),
      ]
    )
  end

  defp process_pattern(pattern) do
    J.identifier("null")
  end

  defp process_guard(guard) do
    J.identifier("null")
  end

  defp process_body(body) do
    J.identifier("null")
  end
end
