answer(ok).
why(
  answer(ok),
  proof(
    goal(answer(ok)),
    by(rule("<stdin>", clause(3))),
    uses([
      proof(
        goal(not(known(b))),
        by(builtin(not, 1))
      )
    ])
  )
).

