% compound_name_arguments/3 observes atoms as name plus empty argument list.
materialize(answer, 2).
answer(Name, Args) :- compound_name_arguments(nil, Name, Args).
