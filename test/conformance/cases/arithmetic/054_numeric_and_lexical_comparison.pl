% Reference 9.3: comparisons handle numeric and lexical scalar ordering.
answer(numeric_gt, true) :- gt(10, 2).
answer(numeric_le, true) :- le(2, 2.0).
answer(lexical_ge, true) :- ge(beta, alpha).
materialize(answer, 2).
