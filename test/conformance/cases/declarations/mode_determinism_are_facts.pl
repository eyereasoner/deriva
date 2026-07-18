% Advisory declarations are also ordinary facts that programs can inspect.
mode(path, 2, [in, out]).
semidet(edge, 2).
det(root, 1).
materialize(answer, 2).
answer(mode, Modes) :- mode(path, 2, Modes).
answer(semidet, edge) :- semidet(edge, 2).
answer(det, root) :- det(root, 1).
