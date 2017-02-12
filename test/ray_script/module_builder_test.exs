defmodule RayScript.ModuleBuilder.Test do
  use ExUnit.Case
  alias RayScript.ModuleBuilder, as: M

  test "module attribute" do
    abs = [{:attribute, 0, :module, Mod}]
    result = M.build(abs)
    assert result.module == Mod
  end
  
  test "file attribute" do
    abs = [{:attribute, 1, :file, {'test/support/empty.erl', 1}}]
    result = M.build(abs)
    assert result.file == "test/support/empty.erl"
  end

  test "export attribute" do
    abs = [{:attribute, 1, :export, [__info__: 1, goodbye: 0, hello: 0]}]
    result = M.build(abs)
    assert result.export == [__info__: 1, goodbye: 0, hello: 0]
  end

  test "function declaration" do
    abs = [{:function, 9, :hello, 1, []}]
    result = M.build(abs)
    assert length(result.body) == 1
    assert hd(result.body).type == "VariableDeclaration"
  end

  test "ignore unknown" do
    abs = [{:something, 9, :hello, 1, []}]
    result = M.build(abs)
    assert result == %RayScript.Module{}
  end

  test "to_js_module" do
    result = [{:attribute, 1, :export, [__info__: 1]}]
    |> M.build
    |> M.to_js_module

    assert result.type == "Program"
    assert length(result.body) == 1
    assert hd(result.body).type == "ExportDefaultDeclaration"
  end   
end
