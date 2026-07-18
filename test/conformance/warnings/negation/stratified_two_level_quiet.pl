materialize(answer, 1).
base(a).
blocked(b).
allowed(X) :- base(X), not(blocked(X)).
answer(X) :- allowed(X).
