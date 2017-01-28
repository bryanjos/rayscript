defmodule RayScript.Translator do
  alias ESTree.Tools.Builder, as: J

  def translate(ast, _opts) do
    do_translate(ast, _opts)
  end

  defp do_translate({:c_module, _, {:c_literal, _, module_name}, exports, _specs, _body}, _) do
    js_exports = process_exports(exports)

    J.program([js_exports], :module)
  end

  defp process_exports(exports) when is_list(exports) do
    properties = exports
    |> Enum.reduce(MapSet.new, fn({:c_var, _, {name, _}}, acc) ->
      MapSet.put(acc, name)
    end)
    |> Enum.map(fn(name) ->
      J.property(J.identifier(name), J.identifier(name), :init, true)
    end)
    |> J.object_expression
    |> J.export_default_declaration
  end

end
