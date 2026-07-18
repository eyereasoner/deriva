materialize(answer, 1).
answer(compound_name_arguments_bad_args_fails) :- compound_name_arguments(_, pair, not_a_list).
