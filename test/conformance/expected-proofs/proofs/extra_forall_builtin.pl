answer(forall_builtin).
why(
  answer(forall_builtin),
  proof(
    goal(answer(forall_builtin)),
    by(rule("<stdin>", clause(2))),
    uses([
      proof(
        goal(forall(member(X, [1, 2]), lt(X, 3))),
        by(builtin(forall, 2))
      )
    ])
  )
).

