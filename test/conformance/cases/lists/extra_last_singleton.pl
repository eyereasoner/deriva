materialize(answer, 2).
answer(last_singleton, X) :- last([only], X).
