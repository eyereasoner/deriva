materialize(answer, 2).
answer(floor, X) :- floor(-1.2, X).
answer(ceiling, X) :- ceiling(-1.2, X).
answer(trunc, X) :- trunc(-1.8, X).
answer(rounded, X) :- rounded(-1.5, X).
