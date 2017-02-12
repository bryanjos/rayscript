defmodule RayScriptTest do
  use ExUnit.Case
  doctest RayScript

  #test "compile empty Elixir module" do
  #  path = Path.join([Mix.Project.build_path(), "lib", "rayscript", "ebin", "Elixir.Empty.beam"])
  #  result = RayScript.compile_module(path)
  #end

  #test "compile empty Erlang module" do
  #  result = RayScript.compile_module(:empty)
  #end
end
