materialize(answer, 1).
answer(X) :- eq(pair(X, box(X)), pair(a, box(a))).
