defmodule Empty do

  def hello(_) do
    :atom
    1
    {1, 2, :a}
    nil
    "string"
    "hello" <> "world"
    <<1, 2, 3, 4, 5>>
    rest = "oo"
    <<102, rest::binary>>
    <<"foo"::utf16>>
    <<102::integer-native, rest::binary>>
    <<102::native-integer, rest::binary>>
    <<102::unsigned-big-integer, rest::binary>>
    <<102::unsigned-big-integer-size(8), rest::binary>>
    <<102::unsigned-big-integer-8, rest::binary>>
    <<102::8-integer-big-unsigned, rest::binary>>
    true
    [1, 2, 3, 4]
    React.DOM.createElement(1, 2, 3)

    rest.createElement(1, 2, 3)

    Enum.map([], fn(x) -> x end)

    1 + 1
    %{a: 1}
  end
end
