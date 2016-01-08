-module(check_array).

-export([
         check/1
        ]).

-spec check(list(integer())) -> {ok, pos_integer()} | never.
check(L) ->
    Initial = prepare_storage(),
    Filled = fill_storage(Initial, L),
    Idx = 0,
    Jumps = 1,
    check_priv(Idx, Jumps, Filled).

%% ===================================================================
%% Internal functions
%% ===================================================================

prepare_storage() ->
    ets:new(?MODULE, [set]).

fill_storage(Storage, L) ->
    lists:foldl(fun store_one_item/2, {0, Storage}, L).

store_one_item(Val, {Idx, Storage}) ->
    Item = {Idx, Val, free},
    ets:insert(Storage, Item),
    {Idx + 1, Storage}.

fetch_one_item(Idx, Storage) ->
    [Item] = ets:lookup(Storage, Idx),
    Item.

check_priv(Idx, Jumps, {Size, Storage}) ->
    Updated = mark_used_index(Idx, Storage),
    Next = get_next_idx(Idx, Updated),
    case check_index(Next, Size, Updated) of
        outside ->
            {ok, Jumps};
        loop ->
            never;
        inside ->
            check_priv(Next, Jumps + 1, {Size, Updated})
    end.

mark_used_index(Idx, Storage) ->
    {_, Val, _} = fetch_one_item(Idx, Storage),
    Item = {Idx, Val, used},
    ets:insert(Storage, Item),
    Storage.

get_next_idx(Idx, Storage) ->
    {_, Val, _} = fetch_one_item(Idx, Storage),
    Idx + Val.

check_index(Idx, _, _) when Idx < 0 ->
    outside;
check_index(Idx, Size, _) when Idx >= Size ->
    outside;
check_index(Idx, _, Storage) ->
    case fetch_one_item(Idx, Storage) of
        {_, _, used} ->
            loop;
        {_, _, free} ->
            inside
    end.

