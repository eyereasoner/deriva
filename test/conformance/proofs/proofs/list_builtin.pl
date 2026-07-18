% Reference 12: proof output preserves list read-back for built-in goals.
materialize(answer, 1).
answer(X) :- member(X, [a, b]), eq(X, b).
