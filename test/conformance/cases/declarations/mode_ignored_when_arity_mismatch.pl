% Invalid advisory mode length is ignored as metadata but remains a fact.
materialize(answer, 1).
mode(edge, 2, [in]).
edge(a, b).
answer(ok) :- mode(edge, 2, [in]), edge(a, b).
