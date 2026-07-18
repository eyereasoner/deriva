% Reference 9.1: term-inspection built-ins expose scalars, nested arguments, and atom construction from an empty argument list.
materialize(answer, 2).
answer(functor_atom, pair(Name, Arity)) :- functor(alpha, Name, Arity).
answer(functor_number, pair(Name, Arity)) :- functor(42, Name, Arity).
answer(functor_string, pair(Name, Arity)) :- functor("hi", Name, Arity).
answer(arg_nested, X) :- arg(1, path(edge(a, b), c), X).
answer(compose_nested, X) :- compound_name_arguments(X, outer, [inner(a), [b, c]]).
answer(compose_atom_empty_args, X) :- compound_name_arguments(X, z, []).
answer(decompose_atom_empty_args, pair(Name, Args)) :- compound_name_arguments(z, Name, Args).
answer(arg_zero_rejected, ok) :- not(arg(0, edge(a, b), X)).
answer(arg_too_large_rejected, ok) :- not(arg(3, edge(a, b), X)).
