% Atoms are zero-arity terms for functor/3.
materialize(answer, 2).
answer(Name, Arity) :- functor(nil, Name, Arity).
