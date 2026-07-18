% Parentheses may group a body conjunction without changing meaning.
materialize(answer, 1).
a(ok).
b(ok).
answer(X) :- (a(X), b(X)).
