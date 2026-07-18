% Each `_` occurrence is fresh, so these two goals do not have to agree.
materialize(answer, 1).
pair(a, b).
answer(ok) :- pair(_, _).
