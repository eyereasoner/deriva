% materialize/2 prints derived answers, not source facts for the same predicate.
materialize(answer, 1).
seed(a).
answer(source).
answer(X) :- seed(X).
