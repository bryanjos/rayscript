-module(empty).
-record(person, {name, phone, address}).
-export([]).

lookup(Name, List) ->
    fun lists:append/2.

xyz(p) -> fun lookup/2.
