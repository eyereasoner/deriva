materialize(answer, 3).
score(2, first).
score(1, keep).
score(1, also).
answer(aggregate_min_tie_first, Key, Value) :- aggregate_min(K, V, score(K, V), Key, Value).
