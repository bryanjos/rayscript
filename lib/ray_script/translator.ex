defmodule RayScript.Translator do
  alias ESTree.Tools.Builder, as: J

  def translate(ast, _opts) do
    do_translate(ast, _opts)
  end

  defp do_translate({:c_module, _, {:c_literal, _, module_name}, exports, _specs, body}, _) do
    js_exports = process_exports(exports)
    js_body = process_body(body)
    J.program(js_body ++ [js_exports], :module)
  end

  defp process_exports(exports) when is_list(exports) do
    properties = exports
    |> Enum.reduce(MapSet.new, fn({:c_var, _, {name, _}}, acc) ->
      MapSet.put(acc, name)
    end)
    |> Enum.map(fn(name) ->
      J.property(J.identifier(name), J.identifier(name), :init, true)
    end)
    |> J.object_expression
    |> J.export_default_declaration
  end

  defp process_body(body) do
    Enum.map(body, &process_function(&1))
  end

  defp process_function({{:c_var, _, {name, arity}}, {:c_fun, _, params, function_body}}) do
    params = Enum.map(params, &process(&1))
    body = process(function_body)
    |> List.wrap
    |> List.flatten
    |> J.block_statement

    declarator = J.variable_declarator(
      J.identifier("#{name}_#{arity}"),
      J.function_expression(params, [], body)
    )

    J.variable_declaration([declarator], :const)
  end

  defp process({:c_call, _,
                     {:c_literal, _, module},
                     {:c_literal, _, function},
                     params}) do

    J.call_expression(
      J.member_expression(
        J.identifier(module),
        J.identifier(function)
      ),
      Enum.map(params, &process(&1))
    )
  end

  defp process({:c_apply, _,
                {:c_var, _, {name, arity}},
                params}) do

    J.call_expression(
      J.identifier("#{name}_#{arity}"),
      Enum.map(params, &process(&1))
    )
  end

  defp process({:c_case, _, _subject, _clauses}) do
    J.identifier("a")
  end

  defp process({:c_var, _, param}) do
    J.identifier(param)
  end

  defp process({:c_literal, _, param}) when is_atom(param) do
    J.call_expression(
      J.member_expression(
        J.identifier("Symbol"),
        J.identifier("for")
      ),
      [J.literal("#{ inspect param }")]
    )
  end

  defp process({:c_literal, _, param}) when is_number(param) or is_binary(param) do
    J.literal(param)
  end

  defp process({:c_literal, _, param}) when is_list(param) do
    items = Enum.map(param, &process(&1))
    J.array_expression(items)
  end

  defp process({:c_literal, _, param}) when is_tuple(param) do
    items = Enum.map(Tuple.to_list(param), &process(&1))
    J.new_expression(
      J.identifier("Tuple"),
      items
    )
  end

  defp process(param) when is_number(param) or is_binary(param) do
    J.literal(param)
  end

  defp process(param) when is_tuple(param) do
    case elem(param, 0) do
      :c_let ->
        process_let(param)
      _ ->
        param
    end
  end

  defp process_let(param) do
    let_list = Tuple.to_list(param)
    [:c_let, _, [p], v | rest] = let_list

    declarator = J.variable_declarator(
      process(p),
      process(v)
    )

    declaration = J.variable_declaration([declarator], :const)

    case rest do
      [] ->
        declaration
      [l] ->
        a = [declaration] ++ List.wrap(process(l))
        List.flatten(a)
    end
  end

end
