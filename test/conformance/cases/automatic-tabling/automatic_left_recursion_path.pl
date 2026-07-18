materialize(answer, 1).
edge(a, b).
edge(b, c).
reachable(X, Z) :- reachable(X, Y), edge(Y, Z).
reachable(X, Y) :- edge(X, Y).
answer(X) :- reachable(a, X).
