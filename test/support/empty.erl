-module(empty).
-record(person, {name, phone, address}).
-export([]).

lookup(Name, List) ->
    fun erlang:send/2.


xyz(p) -> fun lookup/2.
