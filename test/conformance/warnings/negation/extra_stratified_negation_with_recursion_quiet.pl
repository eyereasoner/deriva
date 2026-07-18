materialize(open, 1).
edge(a, b).
path(X, Y) :- edge(X, Y).
closed(c).
open(X) :- path(a, X), not(closed(X)).
