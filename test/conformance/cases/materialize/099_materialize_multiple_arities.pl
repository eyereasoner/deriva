% Reference 11.2 and 13: materialize/2 can select several predicate arities explicitly.
materialize(answer, 1).
materialize(answer, 2).
seed(a).
seed(b).
answer(X) :- seed(X).
answer(X, doubled) :- seed(X).
answer(hidden, X, Y) :- seed(X), seed(Y).
