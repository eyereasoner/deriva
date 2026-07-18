% Reference 9.2: transcendental functions have stable exact outputs at simple inputs.
materialize(answer, 2).
answer(sin_zero, X) :- sin(0, X).
answer(cos_zero, X) :- cos(0, X).
answer(tan_zero, X) :- tan(0, X).
answer(exp_zero, X) :- exp(0, X).
answer(log_one, X) :- log(1, X).
answer(atan2_zero, X) :- atan2(0, 1, X).
answer(sqrt_one, X) :- sqrt(1, X).
