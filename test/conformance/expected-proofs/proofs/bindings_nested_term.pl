answer(pair(a, [b, c])).
why(
  answer(pair(a, [b, c])),
  proof(
    goal(answer(pair(a, [b, c]))),
    by(rule("<stdin>", clause(3))),
    bindings([binding("Term", pair(a, [b, c]))]),
    uses([
      proof(
        goal(source(pair(a, [b, c]))),
        by(fact("<stdin>", clause(2)))
      )
    ])
  )
).

