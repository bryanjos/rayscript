defmodule RayScript.AtomicLiteral.Test do
  use ExUnit.Case
  alias RayScript.Translator, as: T

  test "atom" do
    abs = {:atom, 0, :my_atom}
    result = T.process(abs)
    
    assert result.type == "CallExpression"
    assert result.callee.object.name == "Symbol"
    assert result.callee.property.name == "for"    
    assert hd(result.arguments).value == "my_atom"
  end

  test "nil" do
    abs = {:atom, 0, nil}
    result = T.process(abs)
    
    assert result.type == "Identifier"
    assert result.name == "null"
  end

  test "boolean" do
    abs = {:atom, 0, true}
    result = T.process(abs)
    
    assert result.type == "Literal"
    assert result.value == true
  end      

  test "char" do
    abs = {:char, 0, 'a'}
    result = T.process(abs)  

    assert result.type == "Literal"    
    assert result.value == "a"
  end

  test "float" do
    abs = {:float, 0, 1.5}
    result = T.process(abs)  

    assert result.type == "Literal"
    assert result.value == 1.5
  end

  test "integer" do
    abs = {:integer, 0, 1}
    result = T.process(abs)  

    assert result.type == "Literal"
    assert result.value == 1
  end

  test "string" do
    abs = {:string, 0, 'abcdefg'}
    result = T.process(abs)  

    assert result.type == "Literal"
    assert result.value == "abcdefg"
  end
end
