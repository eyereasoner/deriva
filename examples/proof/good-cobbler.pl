is(test, is(joe, good(cobbler))).
why(
  is(test, is(joe, good(cobbler))),
  proof(
    goal(is(test, is(joe, good(cobbler)))),
    by(rule("good-cobbler.pl", clause(3))),
    bindings([binding("X", joe), binding("Y", cobbler)]),
    uses([
      proof(
        goal(assertedIs(joe, good(cobbler))),
        by(fact("good-cobbler.pl", clause(2)))
      )
    ])
  )
).

