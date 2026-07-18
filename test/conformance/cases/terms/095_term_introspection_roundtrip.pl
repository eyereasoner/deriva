% Reference 9.10: term inspection can decompose and recompose compound terms.
materialize(answer, 2).
answer(functor_compound, pair(Name, Arity)) :- functor(edge(a, b), Name, Arity).
answer(arg_first, X) :- arg(1, edge(a, b), X).
answer(arg_second, X) :- arg(2, edge(a, b), X).
answer(decompose, pair(Name, Args)) :- compound_name_arguments(edge(a, b), Name, Args).
answer(recompose, X) :- compound_name_arguments(X, edge, [a, b]).
answer(roundtrip, X) :- compound_name_arguments(edge(a, b), Name, Args), compound_name_arguments(X, Name, Args).
