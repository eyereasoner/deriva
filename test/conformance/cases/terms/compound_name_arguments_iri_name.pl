materialize(answer, 2).
answer(Name, Args) :- compound_name_arguments('<urn:example:a>', Name, Args).
