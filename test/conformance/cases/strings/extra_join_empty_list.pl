materialize(answer, 2).
answer(join_empty_list, X) :- join([], ",", X).
