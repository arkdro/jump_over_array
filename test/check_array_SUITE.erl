-module(check_array_SUITE).

-include_lib("eunit/include/eunit.hrl").
-include_lib("common_test/include/ct.hrl").

-define(ASSERT, true).

-compile([export_all]).

suite() ->
    [
     {timetrap, {seconds, 180}}
    ].

all() ->
    [
     {group, all}
    ].

groups() ->
    [
     {all, [], [
                {group, checks}
               ]},
     {checks, [], [
                   check_simple_ok,
                   check_simple_never
                  ]}
    ].

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

check_simple_ok(_) ->
    L = [2, 3, -1, 1, 3],
    {ok, 4} = check_array:check(L),
    ok.

check_simple_never(_) ->
    L = [1, 1, -1, 1],
    never = check_array:check(L),
    ok.

