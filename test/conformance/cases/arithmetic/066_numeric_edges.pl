% Reference 9.1: reusable numeric functions preserve integer paths and define finite failure modes.
materialize(answer, 2).
answer(max_negative, X) :- max(-10, -3, X).
answer(min_float, X) :- min(2.5, -1.25, X).
answer(floor_negative, X) :- floor(-3.1, X).
answer(ceiling_negative, X) :- ceiling(-3.9, X).
answer(trunc_positive, X) :- trunc(3.9, X).
answer(sqrt_fraction, X) :- sqrt(2.25, X).
answer(pow_fraction, X) :- pow(9, 0.5, X).
answer(sqrt_negative_rejected, ok) :- not(sqrt(-1, X)).
answer(log_zero_rejected, ok) :- not(log(0, X)).
answer(div_zero_rejected, ok) :- not(div(1, 0, X)).
answer(mod_float_rejected, ok) :- not(mod(5.5, 2, X)).
answer(pow_negative_integer_exponent_rejected, ok) :- not(pow(2, -1, X)).
