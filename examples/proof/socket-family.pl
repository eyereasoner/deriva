ancestor(pat, jan).
why(
  ancestor(pat, jan),
  proof(
    goal(ancestor(pat, jan)),
    by(rule("socket-family.pl", clause(6))),
    bindings([binding("X", pat), binding("Y", jan)]),
    uses([
      proof(
        goal(parent(pat, jan)),
        by(fact("socket-family.pl", clause(4)))
      )
    ])
  )
).

ancestor(jan, emma).
why(
  ancestor(jan, emma),
  proof(
    goal(ancestor(jan, emma)),
    by(rule("socket-family.pl", clause(6))),
    bindings([binding("X", jan), binding("Y", emma)]),
    uses([
      proof(
        goal(parent(jan, emma)),
        by(fact("socket-family.pl", clause(5)))
      )
    ])
  )
).

ancestor(pat, emma).
why(
  ancestor(pat, emma),
  proof(
    goal(ancestor(pat, emma)),
    by(rule("socket-family.pl", clause(7))),
    bindings([binding("X", pat), binding("Z", emma), binding("Y", jan)]),
    uses([
      proof(
        goal(parent(pat, jan)),
        by(fact("socket-family.pl", clause(4)))
      ),
      proof(
        goal(ancestor(jan, emma)),
        by(rule("socket-family.pl", clause(6))),
        bindings([binding("X", jan), binding("Y", emma)]),
        uses([
          proof(
            goal(parent(jan, emma)),
            by(fact("socket-family.pl", clause(5)))
          )
        ])
      )
    ])
  )
).

