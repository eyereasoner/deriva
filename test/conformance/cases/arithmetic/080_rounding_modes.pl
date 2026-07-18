% Reference 9.2: rounding built-ins have distinct behavior for positive and negative decimals.
materialize(answer, 2).
answer(floor_pos, X) :- floor(3.9, X).
answer(floor_neg, X) :- floor(-3.1, X).
answer(ceiling_pos, X) :- ceiling(3.1, X).
answer(ceiling_neg, X) :- ceiling(-3.9, X).
answer(trunc_pos, X) :- trunc(3.9, X).
answer(trunc_neg, X) :- trunc(-3.9, X).
answer(round_half_up, X) :- rounded(2.5, X).
answer(round_half_neg, X) :- rounded(-2.5, X).
