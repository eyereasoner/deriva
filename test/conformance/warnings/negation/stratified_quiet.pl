% Stratified negation emits no portability warning.
materialize(answer, 1).
candidate(a).
answer(ok) :- candidate(a), not(blocked(a)).
