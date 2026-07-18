answer(5).
why(
  answer(5),
  proof(
    goal(answer(5)),
    by(rule("<stdin>", clause(2))),
    bindings([binding("X", 5)]),
    uses([
      proof(
        goal(add(2, 3, 5)),
        by(builtin(add, 3))
      )
    ])
  )
).

