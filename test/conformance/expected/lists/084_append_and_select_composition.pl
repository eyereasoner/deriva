answer(split, pair([], [x, y, z])).
answer(split, pair([x], [y, z])).
answer(split, pair([x, y], [z])).
answer(split, pair([x, y, z], [])).
answer(select_middle, [x, z]).
answer(select_duplicate, pair(a, [b, a])).
answer(select_duplicate, pair(b, [a, a])).
answer(select_duplicate, pair(a, [a, b])).
answer(rebuild, [a, b, c, d]).
answer(no_select_rejected, ok).
