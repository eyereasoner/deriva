% `memoize/2` is no longer a declaration, but it remains an ordinary fact.
materialize(answer, 2).
memoize(path, 2).
answer(Name, Arity) :- memoize(Name, Arity).
