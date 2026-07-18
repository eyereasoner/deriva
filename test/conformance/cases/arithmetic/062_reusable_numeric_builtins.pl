% Reference 9.1: reusable numeric functions and max/3.
materialize(answer, 2).
answer(max, X) :- max(17, 42, X).
answer(sqrt, X) :- sqrt(81, X).
answer(floor, X) :- floor(3.9, X).
answer(ceiling, X) :- ceiling(3.1, X).
answer(trunc, X) :- trunc(-3.9, X).
answer(exp, X) :- exp(0, X).
answer(tan, X) :- tan(0, X).
answer(atan2, X) :- atan2(0, -1, X).
