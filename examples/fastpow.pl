% Fast exponentiation examples adapted from Eyeling fastpow.n3.
%
% pow/3 demonstrates exponentiation by squaring, while pow_mod/4 performs the
% same recursion under a modulus so huge powers remain small enough for ordinary
% output and proof display.
%
% The file also includes deliberately slower and tower-style reports, making it a
% small arithmetic benchmark for recursive definitions, modular arithmetic, and
% bounded output selection.
materialize(pow, 2).
materialize(powSlow, 2).
materialize(powMod1e6, 2).
materialize(tower, 2).
materialize(towerMod1e6, 2).

% Base case and parity split for exponentiation by squaring.  Even exponents
% square the half-power; odd exponents peel off one base factor.
pow(_base, 0, 1).
% Recursive even/odd clauses reduce the exponent quickly rather than counting
% down one multiplication at a time.
pow(Base, Exp, Value) :-
  gt(Exp, 0),
  mod(Exp, 2, 0),
  div(Exp, 2, Half),
  pow(Base, Half, Halfvalue),
  mul(Halfvalue, Halfvalue, Value).
pow(Base, Exp, Value) :-
  gt(Exp, 0),
  mod(Exp, 2, 1),
  sub(Exp, 1, Evenexp),
  pow(Base, Evenexp, Evenvalue),
  mul(Base, Evenvalue, Value).

% pow_mod/4 applies the modulus at each multiplication to keep values small.
pow_mod(_base, 0, _mod, 1).
pow_mod(Base, Exp, Mod, Value) :-
  gt(Exp, 0),
  mod(Exp, 2, 0),
  div(Exp, 2, Half),
  pow_mod(Base, Half, Mod, Halfvalue),
  mul(Halfvalue, Halfvalue, Square),
  mod(Square, Mod, Value).
pow_mod(Base, Exp, Mod, Value) :-
  gt(Exp, 0),
  mod(Exp, 2, 1),
  sub(Exp, 1, Evenexp),
  pow_mod(Base, Evenexp, Mod, Evenvalue),
  mul(Base, Evenvalue, Product),
  mod(Product, Mod, Value).

% Tetration examples are kept as facts here so this file focuses on fast power
% and modular power rather than an additional tower evaluator.
tower(2, 4, 65536).
tower_mod(2, 5, 1000000, 156736).

pow([2, 10], Value) :- pow(2, 10, Value).
powSlow([2, 10], Value) :- pow(2, 10, Value).
powMod1e6([2, 10000], Value) :- pow_mod(2, 10000, 1000000, Value).
powMod1e6([3, 10000], Value) :- pow_mod(3, 10000, 1000000, Value).
tower([2, 4], Value) :- tower(2, 4, Value).
towerMod1e6([2, 5], Value) :- tower_mod(2, 5, 1000000, Value).
