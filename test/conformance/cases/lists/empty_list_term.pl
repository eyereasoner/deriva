% The empty list is a first-class term.
materialize(answer, 1).
seed([]).
answer(X) :- seed(X).
