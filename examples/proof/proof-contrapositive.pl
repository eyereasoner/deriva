refutes(proof1, raining).
why(
  refutes(proof1, raining),
  proof(
    goal(refutes(proof1, raining)),
    by(rule("proof-contrapositive.pl", clause(7))),
    uses([
      proof(
        goal(false(raining)),
        by(rule("proof-contrapositive.pl", clause(6))),
        bindings([binding("A", raining), binding("B", wet_ground)]),
        uses([
          proof(
            goal(implies(raining, wet_ground)),
            by(fact("proof-contrapositive.pl", clause(4)))
          ),
          proof(
            goal(false(wet_ground)),
            by(fact("proof-contrapositive.pl", clause(5)))
          )
        ])
      )
    ])
  )
).

method(proof1, contrapositive).
why(
  method(proof1, contrapositive),
  proof(
    goal(method(proof1, contrapositive)),
    by(rule("proof-contrapositive.pl", clause(8))),
    uses([
      proof(
        goal(false(raining)),
        by(rule("proof-contrapositive.pl", clause(6))),
        bindings([binding("A", raining), binding("B", wet_ground)]),
        uses([
          proof(
            goal(implies(raining, wet_ground)),
            by(fact("proof-contrapositive.pl", clause(4)))
          ),
          proof(
            goal(false(wet_ground)),
            by(fact("proof-contrapositive.pl", clause(5)))
          )
        ])
      )
    ])
  )
).

reason(proof1, "if rain implies wet ground and the ground is not wet, then it is not raining").
why(
  reason(proof1, "if rain implies wet ground and the ground is not wet, then it is not raining"),
  proof(
    goal(reason(proof1, "if rain implies wet ground and the ground is not wet, then it is not raining")),
    by(rule("proof-contrapositive.pl", clause(9))),
    uses([
      proof(
        goal(false(raining)),
        by(rule("proof-contrapositive.pl", clause(6))),
        bindings([binding("A", raining), binding("B", wet_ground)]),
        uses([
          proof(
            goal(implies(raining, wet_ground)),
            by(fact("proof-contrapositive.pl", clause(4)))
          ),
          proof(
            goal(false(wet_ground)),
            by(fact("proof-contrapositive.pl", clause(5)))
          )
        ])
      )
    ])
  )
).

