type(socrates, mortal).
why(
  type(socrates, mortal),
  proof(
    goal(type(socrates, mortal)),
    by(rule("socrates.pl", clause(4))),
    bindings([binding("X", socrates)]),
    uses([
      proof(
        goal(type(socrates, man)),
        by(fact("socrates.pl", clause(3)))
      )
    ])
  )
).

is(test, true).
why(
  is(test, true),
  proof(
    goal(is(test, true)),
    by(rule("socrates.pl", clause(5))),
    uses([
      proof(
        goal(type(socrates, mortal)),
        by(rule("socrates.pl", clause(4))),
        bindings([binding("X", socrates)]),
        uses([
          proof(
            goal(type(socrates, man)),
            by(fact("socrates.pl", clause(3)))
          )
        ])
      )
    ])
  )
).

