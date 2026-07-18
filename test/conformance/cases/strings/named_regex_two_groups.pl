materialize(answer, 2).
answer(First, Last) :- matches("Ada Lovelace", "^(?<first>[A-Za-z]+) (?<last>[A-Za-z]+)$", Ctx), holds(Ctx, first, First), holds(Ctx, last, Last).
