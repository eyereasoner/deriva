% Reference 5.5, 7: parenthesized comma terms are conjunctions in goal position.
p(a).
q(a).
ok(X, yes) :- (p(X), q(X)).
materialize(ok, 2).
