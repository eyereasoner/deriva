% Arity-zero data is represented as atoms, never zero-arity compounds.
materialize(answer, 2).
answer(name, Name) :- compound_name_arguments(nil, Name, Args).
answer(args, Args) :- compound_name_arguments(nil, Name, Args).
answer(term, Term) :- compound_name_arguments(Term, nil, []).
