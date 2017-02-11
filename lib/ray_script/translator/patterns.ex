defmodule RayScript.Translator.Patterns do
  alias ESTree.Tools.Builder, as: JS
  alias RayScript.Translator
  alias RayScript.Translator.Bitstring

  @patterns JS.identifier("Patterns")

  @wildcard JS.member_expression(
    @patterns,
    JS.identifier(:wildcard)
  )

  @parameter JS.member_expression(
    @patterns,
    JS.identifier(:variable)
  )

  @head_tail JS.member_expression(
    @patterns,
    JS.identifier(:headTail)
  )

  @starts_with JS.member_expression(
    @patterns,
    JS.identifier(:startsWith)
  )

  @capture JS.member_expression(
    @patterns,
    JS.identifier(:capture)
  )

  @bound JS.member_expression(
    @patterns,
    JS.identifier(:bound)
  )

  @_type JS.member_expression(
    @patterns,
    JS.identifier(:type)
  )

  @bitstring_match JS.member_expression(
    @patterns,
    JS.identifier(:bitStringMatch)
  )

  def wildcard() do
    JS.call_expression(
      @wildcard,
      []
    )
  end

  def parameter() do
    JS.call_expression(
      @parameter,
      []
    )
  end

  def parameter(default_value) do
    JS.call_expression(
      @parameter,
      [default_value]
    )
  end

  def head_tail(headParameter, tailParameter) do
    JS.call_expression(
      @head_tail,
      [headParameter, tailParameter]
    )
  end

  def starts_with(prefix) do
    JS.call_expression(
      @starts_with,
      [JS.literal(prefix)]
    )
  end

  def capture(value) do
    JS.call_expression(
      @capture,
      [value]
    )
  end

  def bound(value) do
    JS.call_expression(
      @bound,
      [value]
    )
  end

  def type(prototype, value) do
    JS.call_expression(
      @_type,
      [prototype, value]
    )
  end

  def bitstring_match(values) do
    JS.call_expression(
      @bitstring_match,
      values
    )
  end


  def process(patterns) when is_list(patterns) do
    Enum.map(patterns, &do_process(&1))
    |> reduce_patterns
  end

  defp do_process({:bin, _, [{:bin_element, _, {:string, _, str}, :default, :default}]}) do
    { [JS.literal(str)], [] }
  end

  defp do_process({:bin, _, elements}) do
    params = Enum.reduce(elements, [], fn
      ({:bin_element, _, {:var, _, variable}, _, _}, state) ->
        state ++ [JS.identifier(variable)]
      _, state ->
        state
    end)

    elements = Enum.map(elements, fn
      ({:bin_element, _, { :var, _, _ }, size, type}) ->
        Bitstring.process_bin_element({:bin_element, 0, __MODULE__, size, type})
      x ->
        Bitstring.process_bin_element(x)
    end)

    { [bitstring_match(elements)], params }
  end

  defp do_process({:map, _, props}) do
    properties = Enum.map(props, fn({:map_field_exact, _, key, value}) ->
      {pattern, params} = do_process(value)

      property = case key do
                   _ ->
                     JS.property(
                       Translator.process(key),
                       hd(List.wrap(pattern)), :init, false, false, true
                     )
                 end

      { property, params }
    end)

  {props, params} = Enum.reduce(properties, {[], []}, fn({prop, param}, {props, params}) ->
      { props ++ [prop], params ++ param }
    end)

    { JS.object_expression(List.wrap(props)), params }
  end



  defp do_process({:var, _, :_}) do
    { [wildcard()], [JS.identifier(:undefined)] }
  end

  defp do_process({:var, _, variable}) do
    { [parameter()], [JS.identifier(variable)] }
  end

  defp do_process({:cons, _, head, {type, _, _} = tail}) when not (type in [:cons, :nil])  do
    { head_patterns, head_params } = do_process(head)
    { tail_patterns, tail_params } = do_process(tail)
    params = head_params ++ tail_params

    { [head_tail(hd(head_patterns), hd(tail_patterns))], params }
  end  

  defp do_process({:cons, _, _, {nil, 0}} = cons) do
    { patterns, params } = cons
    |> handle_cons([])
    |> Enum.map(&process([&1]))
    |> reduce_patterns

    { [JS.array_expression(patterns)], params }
  end

  defp do_process({:cons, _, _, {:cons, _, _, _}} = cons) do
    { patterns, params } = cons
    |> handle_cons([])
    |> Enum.map(&process([&1]))
    |> reduce_patterns

    { [JS.array_expression(patterns)], params }
  end

  defp do_process({:tuple, _, list}) do
    { patterns, params } = list
    |> Enum.map(&process([&1]))
    |> reduce_patterns

    pattern = JS.object_expression([
      JS.property(
        JS.identifier("values"),
        JS.array_expression(patterns)
      )
    ])

    { [type(JS.identifier("Tuple"), pattern)], params }
  end

  defp do_process({:match, _, {:var, _, name}, right}) do
    unify(name, right)
  end

  defp do_process({:match, _, left, {:var, _, name}}) do
    unify(name, left)
  end

  defp do_process({:nil, _}) do
    { [JS.array_expression([])], [] }
  end

  defp do_process({type, _, _} = p) when type in [:atom, :char, :float, :integer, :string] do
    { [Translator.process(p)], [] }
  end

  defp reduce_patterns(patterns) do
    patterns
    |> Enum.reduce({ [], [] }, fn({ pattern, new_param }, { patterns, new_params }) ->
      { patterns ++ List.wrap(pattern), new_params ++ List.wrap(new_param) }
    end)
  end

  defp unify(target, source) do
    { patterns, params } = process([source])
    { [capture(hd(patterns))], params ++ [JS.identifier(target)] }
  end

  defp handle_cons({:cons, _, head, {nil, _}}, list) do
    list ++ [head]
  end

  defp handle_cons({:cons, _, head, {:cons, _, _} = tail}, list) do
    list ++ [head] ++ handle_cons(tail, list)
  end  

  defp handle_cons({:cons, _, head, tail}, list) do
    list ++ [head] ++ [tail]
  end

end
