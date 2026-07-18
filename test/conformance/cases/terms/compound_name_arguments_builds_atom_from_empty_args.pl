% Building a term with an empty argument list yields an atom, not nil().
materialize(answer, 1).
answer(Term) :- compound_name_arguments(Term, nil, []).
