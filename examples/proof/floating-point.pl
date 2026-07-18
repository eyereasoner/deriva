value(sum, 3.75).
why(
  value(sum, 3.75),
  proof(
    goal(value(sum, 3.75)),
    by(rule("floating-point.pl", clause(5))),
    bindings([binding("X", 3.75)]),
    uses([
      proof(
        goal(add(1.5, 2.25, 3.75)),
        by(builtin(add, 3))
      )
    ])
  )
).

value(difference, 6.875).
why(
  value(difference, 6.875),
  proof(
    goal(value(difference, 6.875)),
    by(rule("floating-point.pl", clause(6))),
    bindings([binding("X", 6.875)]),
    uses([
      proof(
        goal(sub(10.0, 3.125, 6.875)),
        by(builtin(sub, 3))
      )
    ])
  )
).

value(product, 10.0).
why(
  value(product, 10.0),
  proof(
    goal(value(product, 10.0)),
    by(rule("floating-point.pl", clause(7))),
    bindings([binding("X", 10.0)]),
    uses([
      proof(
        goal(mul(2.5, 4.0, 10.0)),
        by(builtin(mul, 3))
      )
    ])
  )
).

value(quotient, 3.75).
why(
  value(quotient, 3.75),
  proof(
    goal(value(quotient, 3.75)),
    by(rule("floating-point.pl", clause(8))),
    bindings([binding("X", 3.75)]),
    uses([
      proof(
        goal(div(7.5, 2, 3.75)),
        by(builtin(div, 3))
      )
    ])
  )
).

value(sqrtByPower, 3.0).
why(
  value(sqrtByPower, 3.0),
  proof(
    goal(value(sqrtByPower, 3.0)),
    by(rule("floating-point.pl", clause(9))),
    bindings([binding("X", 3.0)]),
    uses([
      proof(
        goal(pow(9.0, 0.5, 3.0)),
        by(builtin(pow, 3))
      )
    ])
  )
).

value(mathSum, 1.0).
why(
  value(mathSum, 1.0),
  proof(
    goal(value(mathSum, 1.0)),
    by(rule("floating-point.pl", clause(10))),
    bindings([binding("X", 1.0)]),
    uses([
      proof(
        goal(add(0.125, 0.875, 1.0)),
        by(builtin(add, 3))
      )
    ])
  )
).

value(mathProduct, 3.0).
why(
  value(mathProduct, 3.0),
  proof(
    goal(value(mathProduct, 3.0)),
    by(rule("floating-point.pl", clause(11))),
    bindings([binding("X", 3.0)]),
    uses([
      proof(
        goal(mul(6.0, 0.5, 3.0)),
        by(builtin(mul, 3))
      )
    ])
  )
).

value(comfortable, true).
why(
  value(comfortable, true),
  proof(
    goal(value(comfortable, true)),
    by(rule("floating-point.pl", clause(13))),
    bindings([binding("R", 21.5)]),
    uses([
      proof(
        goal(sample(roomC, 21.5)),
        by(fact("floating-point.pl", clause(3)))
      ),
      proof(
        goal(ge(21.5, 21.0)),
        by(builtin(ge, 2))
      ),
      proof(
        goal(le(21.5, 22.0)),
        by(builtin(le, 2))
      )
    ])
  )
).

than(warmer, targetC).
why(
  than(warmer, targetC),
  proof(
    goal(than(warmer, targetC)),
    by(rule("floating-point.pl", clause(12))),
    bindings([binding("R", 21.5), binding("T", 19.25)]),
    uses([
      proof(
        goal(sample(roomC, 21.5)),
        by(fact("floating-point.pl", clause(3)))
      ),
      proof(
        goal(sample(targetC, 19.25)),
        by(fact("floating-point.pl", clause(4)))
      ),
      proof(
        goal(gt(21.5, 19.25)),
        by(builtin(gt, 2))
      )
    ])
  )
).

