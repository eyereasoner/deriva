materialize(answer, 1).
known(a).
answer(not_with_bound_fails) :- not(known(a)).
