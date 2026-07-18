% Reference 9.5: between/3 enumerates inclusively, checks bound values, and rejects empty ranges.
materialize(answer, 2).
answer(enumerated, X) :- between(-1, 1, X).
answer(check_bound, ok) :- between(1, 3, 2).
answer(check_low_edge, ok) :- between(1, 3, 1).
answer(check_high_edge, ok) :- between(1, 3, 3).
answer(check_outside_rejected, ok) :- not(between(1, 3, 4)).
answer(empty_range_rejected, ok) :- not(between(3, 1, X)).
