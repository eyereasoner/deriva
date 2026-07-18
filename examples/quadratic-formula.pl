% Quadratic formula over sample equations.
%
% Each equation is represented as a*x^2 + b*x + c = 0.  The example uses
% via arithmetic predicates to derive the discriminant and the two roots.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(discriminant, 2).
materialize(root, 2).

% equation/4 stores coefficients A, B, and C for each quadratic.  The examples
% use decimal constants so roots and discriminants flow through floating arithmetic.
equation(eq1, 1.0, -5.0, 6.0).
equation(eq2, 2.0, -4.0, -6.0).

% The formula is decomposed into discriminant, square root, -B, denominator,
% and the plus/minus branches so each algebraic step can be inspected.
discriminant(Case, D) :-
  equation(Case, A, B, C),
  pow(B, 2.0, B2),
  mul(4.0, A, Foura),
  mul(Foura, C, Fourac),
  sub(B2, Fourac, D).

sqrt_discriminant(Case, S) :-
  discriminant(Case, D),
  ge(D, 0.0),
  pow(D, 0.5, S).

negative_b(Case, Nb) :-
  equation(Case, _a, B, _c),
  neg(B, Nb).

denominator(Case, Den) :-
  equation(Case, A, _b, _c),
  mul(2.0, A, Den).

root_plus(Case, Root) :-
  negative_b(Case, Nb),
  sqrt_discriminant(Case, S),
  denominator(Case, Den),
  add(Nb, S, Numerator),
  div(Numerator, Den, Root).

root_minus(Case, Root) :-
  negative_b(Case, Nb),
  sqrt_discriminant(Case, S),
  denominator(Case, Den),
  sub(Nb, S, Numerator),
  div(Numerator, Den, Root).


root(Case, Root) :-
  root_plus(Case, Root).

root(Case, Root) :-
  root_minus(Case, Root).
