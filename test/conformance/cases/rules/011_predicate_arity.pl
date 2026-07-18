% Reference 6: predicate name and arity both identify a predicate group.
p(a).
p(a, b).
answer(unary, X) :- p(X).
answer(binary, pair(X, Y)) :- p(X, Y).
materialize(answer, 2).
