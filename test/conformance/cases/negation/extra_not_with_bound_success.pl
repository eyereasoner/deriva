materialize(answer, 2).
known(a).
answer(not_with_bound_success, b) :- not(known(b)).
