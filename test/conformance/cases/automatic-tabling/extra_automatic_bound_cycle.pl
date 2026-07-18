materialize(reach, 2).
edge(a, b).
edge(b, a).
path(X, Y) :- edge(X, Y).
path(X, Z) :- edge(X, Y), path(Y, Z).
reach(a, X) :- path(a, X).
