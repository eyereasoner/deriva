% Reference 9.9: holds/2 and holds/3 enumerate comma-context terms left to right.
materialize(answer, 2).
context((kind(alert), severity(high), owner(alice))).
answer(term, X) :- context(C), holds(C, X).
answer(parts, pair(Name, Args)) :- context(C), holds(C, Name, Args).
answer(filter, X) :- context(C), holds(C, owner(X)).
answer(missing_rejected, ok) :- context(C), not(holds(C, status(open))).
