% Reference 9.10: not/1, once/1, and forall/2 are scoped control operations.
materialize(answer, 2).
choice(a).
choice(b).
allowed(a).
allowed(b).
answer(once_choice, X) :- once(choice(X)).
answer(negated_missing, ok) :- not(choice(c)).
answer(negated_existing_rejected, ok) :- not(not(choice(a))).
answer(all_allowed, ok) :- forall(choice(X), allowed(X)).
answer(not_all_allowed_after_extra, ok) :- not(forall(extra(X), allowed(X))).
extra(a).
extra(c).
