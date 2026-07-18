% Reference 9.2: scalar arithmetic functions return numeric values.
answer(neg, X) :- neg(5, X).
answer(abs, X) :- abs(-5, X).
answer(rounded, X) :- rounded(2.6, X).
answer(sin_zero, X) :- sin(0, X).
answer(cos_zero, X) :- cos(0, X).
answer(log_one, X) :- log(1, X).
answer(float_division, X) :- div(7.0, 2.0, X).
materialize(answer, 2).
