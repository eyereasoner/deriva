% Reference 12: proof output records the source rule and source fact used for an answer.
materialize(answer, 1).
seed(ok).
answer(X) :- seed(X).
