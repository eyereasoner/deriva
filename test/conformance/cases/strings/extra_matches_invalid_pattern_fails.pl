materialize(answer, 1).
answer(matches_invalid_pattern_fails) :- matches("abc", "[").
