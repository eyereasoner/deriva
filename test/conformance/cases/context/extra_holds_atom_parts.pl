materialize(answer, 3).
answer(holds_atom_parts, Name, Args) :- holds((ready, box(a)), Name, Args).
