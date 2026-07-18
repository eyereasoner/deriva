% Reference 9.3, 9.6: lexical comparison and simple text matching.
answer(matches, true) :- matches("via", "vi").
answer(not_matches, true) :- not_matches("via", "cat").
answer(lex_lt, true) :- lt(alpha, beta).
answer(lex_gt, true) :- gt(beta, alpha).
answer(numeric_le, true) :- le(2, 2).
materialize(answer, 2).
