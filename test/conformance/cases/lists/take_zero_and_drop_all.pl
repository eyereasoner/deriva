materialize(answer, 2).
answer(take, X) :- take(0, [a, b], X).
answer(drop, X) :- drop(2, [a, b], X).
