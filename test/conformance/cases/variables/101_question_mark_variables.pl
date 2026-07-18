% Uppercase variables are ordinary ISO Prolog-style variables.
materialize(answer, 2).
edge(a, b).
edge(b, c).
path(X, Y) :- edge(X, Y).
path(X, Z) :- edge(X, Y), path(Y, Z).
answer(X, Y) :- path(X, Y).
