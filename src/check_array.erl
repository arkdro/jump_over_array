-module(check_array).

-export([
         check/1
        ]).

check(L) ->
    Initial = prepare_storage(),
    Filled = fill_storage(Initial, L),
    erlang:error(not_implemented).

%% ===================================================================
%% Internal functions
%% ===================================================================

prepare_storage() ->
    ets:new(?MODULE, [set]).

fill_storage(Storage, L) ->
    lists:foldl(fun store_one_item/2, {0, Storage}, L).

store_one_item(Val, {Idx, Storage}) ->
    Item = {Idx, Val},
    ets:insert(Storage, Item),
    {Idx + 1, Storage}.

