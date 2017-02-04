defmodule RayScript.Translator do
  alias ESTree.Tools.Builder, as: J
  alias RayScript.Translator.{ Bitstring, Match }

  def process({:clauses, clauses}) do
    processed = Enum.map(clauses, &process(&1))

    J.call_expression(
      J.member_expression(
        J.identifier("Patterns"),
        J.identifier("defmatch")
      ),
      processed
    )
  end

  def process({:clause, _, pattern, guard, body}) do
    {patterns, params} = RayScript.Translator.Patterns.process(pattern)


    J.call_expression(
      J.member_expression(
        J.identifier("Patterns"),
        J.identifier("clause")
      ),
      [
        J.array_expression(patterns),
        process_body(params, body)
      ] ++ process_guard(guard)
    )
  end

  def process({:fun, _, {:clauses, clauses}}) do
    process(clauses)
  end

  def process({:match, _, left, right}) do
    Match.match(left, right)
  end

  def process({:var, _, variable}) do
    J.identifier(variable)
  end

  def process({:atom, _, nil}) do
    J.identifier("null")
  end

  def process({:atom, _, bool}) when is_boolean(bool) do
    J.literal(bool)
  end

  def process({:atom, _, a}) do
    J.call_expression(
      J.member_expression(
        J.identifier("Symbol"),
        J.identifier("for")
      ),
      [J.literal("#{ inspect a}")]
    )
  end

  def process({number, _, n}) when number in [:integer, :float]  do
    J.literal(n)
  end

  def process({:char, _, n})  do
    J.literal(n)
  end

  def process({:tuple, _, items}) do
    J.new_expression(
      J.identifier("Tuple"),
      Enum.map(items, &process(&1))
    )
  end

  def process({:nil, 0}) do
    J.array_expression([])
  end

  def process({:cons, _, _, _} = cons) do
    J.array_expression(handle_cons(cons, []))
  end

  def process({:bin, _, _} = bitstring) do
    Bitstring.process(bitstring)
  end

  def process({:call, _, {:atom, _, name}, params}) do
    arity = length(params)

    J.call_expression(
      J.identifier("#{name}_#{arity}"),
      Enum.map(params, &process(&1))
    )
  end

  def process({:call, _, {:remote, _, {:var, _, v}, {:atom, _, name}}, params}) do
    arity = length(params)

    J.call_expression(
      J.identifier("#{name}_#{arity}"),
      Enum.map(params, &process(&1))
    )
  end

  def process({:call, _, {:remote, _, {:atom, _, module}, {:atom, _, name}}, params}) do
    arity = length(params)

    pieces = String.split(inspect(module), ".")
    pieces = pieces ++ ["#{name}_#{arity}"]
    pieces = Enum.map(pieces, fn(x) -> J.identifier(x) end)

    members = Enum.reduce(pieces, nil, fn(x, ast) ->
      case ast do
        nil ->
          J.member_expression(x, nil)
        %ESTree.MemberExpression{ property: nil } ->
          %{ ast | property: x }
        _ ->
          J.member_expression(ast, x)
      end
    end)


    J.call_expression(
      members,
      Enum.map(params, &process(&1))
    )
  end

  def process({:map, _, properties}) do
    properties = Enum.map(properties, &handle_map_property(&1))
    J.object_expression(properties)
  end

  def process(_) do
    J.identifier("null")
  end

  defp handle_cons({:cons, _, head, {nil, _}}, list) do
    list ++ [process(head)]
  end

  defp handle_cons({:cons, _, head, tail}, list) do
    list ++ [process(head)] ++ handle_cons(tail, list)
  end

  defp handle_map_property({type, _, key, value}) when type in [:map_field_assoc, :map_field_exact] do
    key = process(key)
    value = process(value)
    J.property(key, value, :init, false, false, true)
  end

  defp process_guard([]) do
    []
  end

  defp process_guard(guard) do
    J.identifier("null")
  end

  defp process_body(params, body) do
    body = Enum.map(body, &process(&1))
    |> List.flatten
    |> J.block_statement

    J.function_expression(params, [], body)
  end
end
