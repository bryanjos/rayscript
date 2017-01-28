defmodule RayScriptTest do
  use ExUnit.Case
  doctest RayScript

  test "compile empty module" do
    result = RayScript.compile_module(Empty)
    IO.inspect result
  end
end
