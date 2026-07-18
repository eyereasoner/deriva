% Reference 9.6 and 9.9: matches/3 turns named captures into context terms.
materialize(answer, 2).
line("level=warn code=E42 user=bob").
answer(level, X) :- line(L), matches(L, "level=(?<level>\\w+) code=(?<code>\\w+) user=(?<user>\\w+)", C), holds(C, level(X)).
answer(code, X) :- line(L), matches(L, "level=(?<level>\\w+) code=(?<code>\\w+) user=(?<user>\\w+)", C), holds(C, code(X)).
answer(user, X) :- line(L), matches(L, "level=(?<level>\\w+) code=(?<code>\\w+) user=(?<user>\\w+)", C), holds(C, user(X)).
answer(no_named_groups_rejected, ok) :- not(matches("abc", "a(b)c", C)).
answer(bad_regex_rejected, ok) :- not(matches("abc", "(", C)).
