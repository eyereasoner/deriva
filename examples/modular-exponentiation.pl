% Modular exponentiation by repeated squaring.
%
% pow_mod(Base, Exp, Modulus, Result) uses the even/odd exponent split, giving
% logarithmic-depth arithmetic.  Memoization matters when the same modular powers
% are reused by Fermat-style congruence checks.
materialize(modular_answer, 2).


% Base case: any nonzero base to exponent zero is 1 modulo Mod.
pow_mod(_base, 0, Mod, Result) :- mod(1, Mod, Result).
pow_mod(Base, Exp, Modulus, Result) :-
  gt(Exp, 0),
  mod(Exp, 2, 0),
  div(Exp, 2, Half),
  pow_mod(Base, Half, Modulus, Halfpower),
  mul(Halfpower, Halfpower, Square),
  mod(Square, Modulus, Result).
pow_mod(Base, Exp, Modulus, Result) :-
  gt(Exp, 0),
  mod(Exp, 2, 1),
  sub(Exp, 1, Evenexp),
  pow_mod(Base, Evenexp, Modulus, Evenpower),
  mul(Base, Evenpower, Product),
  mod(Product, Modulus, Result).

% This is a Fermat congruence check, not a full primality proof.
fermat_witness(Base, Primecandidate) :-
  sub(Primecandidate, 1, Exponent),
  pow_mod(Base, Exponent, Primecandidate, 1).

modular_answer(pow_7_560_mod_561, R) :- pow_mod(7, 560, 561, R).
modular_answer(pow_2_1000_mod_1009, R) :- pow_mod(2, 1000, 1009, R).
modular_answer(fermat_2_101, true) :- fermat_witness(2, 101).
modular_answer(fermat_3_101, true) :- fermat_witness(3, 101).
