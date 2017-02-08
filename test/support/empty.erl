-module(empty).
-record(person, {name, phone, address}).
-export([]).

lookup(Name, List) ->
    [ X || <<X>> <= <<1,2,3,4,5>>, X rem 2 == 0].

xyz(p) -> fun lookup/2.
