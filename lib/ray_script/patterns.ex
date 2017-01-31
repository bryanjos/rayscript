defmodule RayScript.Patterns do
  alias ESTree.Tools.Builder, as: JS

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
    {1, 2}
  end

  defp do_process({:var, _, :_}) do
    { [wildcard()], [JS.identifier(:undefined)] }
  end

  defp do_process({:var, _, variable}) do
    { [parameter()], [JS.identifier(variable)] }
  end

  defp do_process({:cons, _, head, tail}) do
    { head_patterns, head_params } = do_process(head)
    { tail_patterns, tail_params } = do_process(tail)
    params = head_params ++ tail_params

    { [head_tail(hd(head_patterns), hd(tail_patterns))], params }
  end

end
