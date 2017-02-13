defmodule RayScript.Translator.Match do
  @moduledoc false
  alias ESTree.Tools.Builder, as: JS
  alias RayScript.Translator
  alias RayScript.Translator.Patterns

  @spec match(tuple, tuple) :: ESTree.Node.t 
  def match(left, right) do
    right_ast = Translator.process(right)

    {patterns, params} = Patterns.process([left])

      declarator = JS.variable_declarator(
        JS.array_pattern(params),
        JS.call_expression(
          JS.member_expression(
            JS.identifier("Patterns"),
            JS.identifier("match")
          ),
          [hd(patterns), right_ast]
        )
      )

    array_pattern = JS.variable_declaration([declarator], :const)

    js_ast = case left do
      list when is_list(list) ->
        make_list_ref(array_pattern, params)
      {_, _} ->
        make_tuple_ref(array_pattern, params)
      {:{}, _, _} ->
        make_tuple_ref(array_pattern, params)
      _ ->
        array_pattern
    end

    js_ast
  end

  defp make_list_ref(array_pattern, params) do
    {ref, params} = make_params(params)

    ref_declarator = JS.variable_declarator(
      ref,
      JS.array_expression(params)
    )

    make_variable_declaration_and_group(ref_declarator, array_pattern)
  end

  defp make_tuple_ref(array_pattern, params) do
    {ref, params} = make_params(params)

    ref_declarator = JS.variable_declarator(
      ref,
      JS.new_expression(
        JS.identifier("Tuple"),
        params
      )
    )

    make_variable_declaration_and_group(ref_declarator, array_pattern)
  end


  defp make_params(params) do
    ref = JS.identifier("_ref")

    params = Enum.map(params, fn
      (nil) -> JS.identifier("undefined")
      (x) -> x
    end)

    {ref, params}
  end

  defp make_variable_declaration_and_group(ref_declarator, array_pattern) do
    ref_declaration = JS.variable_declaration([ref_declarator], :let)
    [array_pattern, ref_declaration]
  end
end
