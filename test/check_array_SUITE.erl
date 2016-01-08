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
                   check1
                  ]}
    ].

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

check1(_Config) ->
    ok.

%% ===================================================================
%% Internal functions
%% ===================================================================

items1() ->
    [1, 1, 1].

