% Reference 9.3: comparison handles numbers, durations, strings, and lexical scalars.
materialize(answer, 2).
answer(integer_order, ok) :- lt(9, 10).
answer(decimal_equal_le, ok) :- le(2.0, 2).
answer(numeric_not_lexical, ok) :- lt(10, 100).
answer(duration_years, ok) :- lt('P1Y', 'P2Y').
answer(duration_months, ok) :- gt('P1Y1M', 'P1Y').
answer(atom_lexical, ok) :- lt(alpha, beta).
answer(string_lexical, ok) :- gt("z", "a").
answer(compound_lexical_text, ok) :- lt(pair(a, 1), pair(b, 1)).
