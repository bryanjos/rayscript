defmodule RayScript.Translator.Bitstring do
  @moduledoc false
  alias ESTree.Tools.Builder, as: J
  alias RayScript.Translator

  @spec process(tuple) :: ESTree.Node.t
  def process({:bin, _, elements}) do
    all_strings = Enum.all?(elements, fn
      {:bin_element, _, {:string, _, _}, :default, :default} -> true
      _ -> false
    end)

    if all_strings do
      process_string(elements)
    else
      elements = Enum.map(elements, &process_bin_element(&1))
      J.new_expression(
        J.identifier("BitString"),
        elements
      )
    end
  end

  defp process_string(elements) do
    elements
    |> Enum.reduce([], fn({:bin_element, _, {:string, _, str}, _, _}, acc) ->
      acc ++ [str]
    end)
    |> Enum.join("")
    |> J.literal
  end

  @spec process_bin_element(tuple) :: ESTree.Node.t
  def process_bin_element(bin_element)

  def process_bin_element({:bin_element, _, RayScript.Translator.Patterns, _, _}) do
    J.object_expression([J.property(
                             J.literal("value"),
                             RayScript.Translator.Patterns.parameter()
                           )
                         ])
  end

  def process_bin_element({:bin_element, _, {:string, _, str}, :default, [attr]}) when attr in [:utf8, :utf16, :utf32] do

    J.call_expression(
      J.member_expression(
        J.identifier("BitString"),
        J.identifier(to_string(attr))
      ),
      [
        J.literal(str)
      ]
    )
  end

  def process_bin_element({:bin_element, _, {type, _, _} = value, :default, :default}) do
    type = case type do 
      :string -> :binary
      :var -> :integer
      _ -> type
    end

    J.call_expression(
      J.member_expression(
        J.identifier("BitString"),
        J.identifier(type)
      ),
      [
        Translator.process(value)
      ]
    )
  end

  def process_bin_element({:bin_element, _, value, {type, _, size}, :default}) do
    type = case type do 
      :string -> :binary
      :var -> :integer
      _ -> type
    end

    inner = J.call_expression(
      J.member_expression(
        J.identifier("BitString"),
        J.identifier(type)
      ),
      [
        Translator.process(value)
      ]
    )

    J.call_expression(
      J.member_expression(
        J.identifier("BitString"),
        J.identifier("size")
      ),
      [
        inner,
        J.literal(size)
      ]
    )
  end

  def process_bin_element({:bin_element, _, {:var, _, var_name}, :default, attrs}) do
    Enum.reduce(attrs, J.identifier(var_name), fn(attr, x) ->
      J.call_expression(
        J.member_expression(
          J.identifier("BitString"),
          J.identifier(attr)
        ),
        [
          x
        ]
      )
    end)
  end

  def process_bin_element({:bin_element, _, {type, _, _} = value, :default, attrs}) do
    type = case type do 
      :string -> :binary
      :var -> :integer
      _ -> type
    end    

    inner = J.call_expression(
      J.member_expression(
        J.identifier("BitString"),
        J.identifier(type)
      ),
      [
        Translator.process(value)
      ]
    )

    Enum.reduce(attrs, inner, fn(attr, x) ->
      J.call_expression(
        J.member_expression(
          J.identifier("BitString"),
          J.identifier(attr)
        ),
        [
          x
        ]
      )
    end)
  end


  def process_bin_element({:bin_element, _, value, {type, _, size}, attrs}) do
    inner = J.call_expression(
      J.member_expression(
        J.identifier("BitString"),
        J.identifier(type)
      ),
      [
        Translator.process(value)
      ]
    )

    size = J.call_expression(
      J.member_expression(
        J.identifier("BitString"),
        J.identifier("size")
      ),
      [
        inner,
        J.literal(size)
      ]
    )

    Enum.reduce(attrs, size, fn(attr, x) ->
      J.call_expression(
        J.member_expression(
          J.identifier("BitString"),
          J.identifier(attr)
        ),
        [
          x
        ]
      )
    end)
  end

end
