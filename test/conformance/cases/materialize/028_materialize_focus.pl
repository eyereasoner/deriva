% Reference 10.2, 11: materialize/2 restricts selected default predicate groups.
materialize(answer, 2).
seed(a).
helper(X, y) :- seed(X).
answer(X, ok) :- helper(X, y).
