defmodule RayScriptTest do
  use ExUnit.Case
  doctest RayScript

  test "compile empty Elixir module" do
    result = RayScript.compile_module(Empty)
  end

  test "compile empty Erlang module" do
    result = RayScript.compile_module(:empty)
  end
end
