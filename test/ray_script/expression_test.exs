defmodule RayScript.Expression.Test do
  use ExUnit.Case
  alias RayScript.Translator, as: T

  test "var" do
    abs = {:var, 0, :my_var}
    result = T.process(abs)
    
    assert result.type == "Identifier"
    assert result.name == :my_var
  end

  test "tuple" do
    abs = {:tuple, 0, [{:atom, 0, :goodbye}, {:integer, 0, 0}]}
    result = T.process(abs)
    
    assert result.type == "NewExpression"
    assert result.callee == %ESTree.Identifier{name: "Tuple"}
    assert length(result.arguments) == 2   
  end

  test "empty list" do
    abs = {nil, 0}
    result = T.process(abs)
    
    assert result.type == "ArrayExpression"
  end   
end
