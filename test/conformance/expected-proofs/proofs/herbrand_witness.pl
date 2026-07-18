has_parent(alice, parent_of(alice)).
why(
  has_parent(alice, parent_of(alice)),
  proof(
    goal(has_parent(alice, parent_of(alice))),
    by(rule("<stdin>", clause(2))),
    bindings([binding("Child", alice)]),
    uses([
      proof(
        goal(person(alice)),
        by(fact("<stdin>", clause(1)))
      )
    ])
  )
).

