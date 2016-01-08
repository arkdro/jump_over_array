-module(check_array).

-export([
         calculate_jumps/1
        ]).

-spec calculate_jumps(list(integer())) -> {ok, pos_integer()} | never.
calculate_jumps(L) ->
    Initial = prepare_storage(),
    Filled = fill_storage(Initial, L),
    Idx = 0,
    Jumps = 1,
    Res = check_priv(Idx, Jumps, Filled),
    clear_storage(Filled),
    Res.

%% ===================================================================
%% Internal functions
%% ===================================================================

prepare_storage() ->
    ets:new(?MODULE, [set]).

clear_storage({_, Storage}) ->
    ets:delete(Storage).

fill_storage(Storage, L) ->
    lists:foldl(fun add_one_item/2, {0, Storage}, L).

add_one_item(Val, {Idx, Storage}) ->
    Updated = store_free_item(Idx, Val, Storage),
    {Idx + 1, Updated}.

store_free_item(Idx, Val, Storage) ->
    store_item(Idx, Val, free, Storage).

store_used_item(Idx, Val, Storage) ->
    store_item(Idx, Val, used, Storage).

store_item(Idx, Val, Usage, Storage) ->
    Item = {Idx, Val, Usage},
    ets:insert(Storage, Item),
    Storage.

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
    store_used_item(Idx, Val, Storage).

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

