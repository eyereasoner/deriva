materialize(answer, 1).
answer(ok) :- not(min_list([], X)).
