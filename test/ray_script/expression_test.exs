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
    assert length(result.elements) == 0  
  end

  test "one character list" do
    abs = {:cons, 0, {:integer, 0, 1}, {nil, 0}}
    result = T.process(abs)
    
    assert result.type == "ArrayExpression"
    assert length(result.elements) == 1    
  end

  test "multiple character list" do
    abs = {:cons, 0, {:integer, 0, 1}, {:cons, 0, {:integer, 0, 1}, {nil, 0}}}
    result = T.process(abs)
    
    assert result.type == "ArrayExpression"
    assert length(result.elements) == 2
  end

  test "fun Name/Arity" do
    abs = {:fun, 0, {:function, :hello, 1}}
    result = T.process(abs)
    
    assert result.type == "Identifier"
    assert result.name == "hello_1"
  end

  test "fun Module:Name/Arity" do
    abs = {:fun, 0, {:function, {:atom, 0, Hello}, {:atom, 0, :world}, {:integer, 0, 1}}}
    result = T.process(abs)
    assert result.type == "MemberExpression"
    assert result.object.name == "Elixir.Hello"
    assert result.property.name == "world_1"    
  end

  test "call" do
    abs = {:call, 0, {:atom, 0, :world},[{:integer, 0, 1}]}
    result = T.process(abs)

    assert result.type == "CallExpression"
    assert result.callee.name == "world_1"
    assert length(result.arguments) == 1   
  end

  test "remote call" do
    abs = {:call, 0, {:remote, 0, {:atom, 0, Hello}, {:atom, 0, :world}}, [{:integer, 0, 1}]}
    result = T.process(abs)

    assert result.type == "CallExpression"
    assert result.callee.object.name == "Elixir.Hello"
    assert result.callee.property.name == "world_1"    
    assert length(result.arguments) == 1
  end

  test "unary operators" do
    operators = [:bnot, :not, :+, :-]

    Enum.each(operators, fn(op) ->
      abs = {:op, 0, op, {:integer, 0, 1}}
      result = T.process(abs)
      assert result.type == "UnaryExpression"      
    end)
  end  

  test "binary operators" do
    operators = [:"=<", :"/=", :"=:=", :"=/=", :div, 
    :rem, :and, :andalso, :or, :orelse, :band, :bor, :bxor, :bsl, :bsr, :<, :>, :==]

    Enum.each(operators, fn(op) ->
      abs = {:op, 0, op, {:integer, 0, 1}, {:integer, 0, 2}}
      result = T.process(abs)
      assert result.type == "BinaryExpression"
      assert result.left.value == 1
      assert result.right.value == 2       
    end)
  end

  test "xor" do
      abs = {:op, 0, :xor, {:integer, 0, 1}, {:integer, 0, 2}}
      result = T.process(abs)
      assert result.type == "BinaryExpression"
  end        
end
