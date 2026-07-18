% Heron's theorem: area = sqrt(s(s-a)(s-b)(s-c)).
%
% The sample is the classic 13-14-15 triangle, whose area is exactly 84.  The
% program materializes the semiperimeter, Heron product, and final area so proof
% output can be checked against the familiar hand calculation.
%
% This is a compact example of theorem-shaped arithmetic: facts name a geometric
% object, reusable relations compute intermediates, and wrapper predicates choose
% the report vocabulary.
materialize(semiperimeter, 2).
materialize(heronProduct, 2).
materialize(area, 2).
materialize(status, 2).

% A single survey triangle is enough to demonstrate the formula; 13-14-15 has
% integer area 84, which makes the computed result easy to check.
triangle(field_plot, 13, 14, 15).

% semiperimeter/2 is the reusable first step in Heron's formula.
semiperimeter(Triangle, S) :-
  triangle(Triangle, A, B, C),
  add(A, B, Ab),
  add(Ab, C, Sum),
  div(Sum, 2, S).

% Area is obtained by taking the square root of this Heron product.
heron_product(Triangle, Product) :-
  triangle(Triangle, A, B, C),
  semiperimeter(Triangle, S),
  sub(S, A, Sa),
  sub(S, B, Sb),
  sub(S, C, Sc),
  mul(S, Sa, T1),
  mul(T1, Sb, T2),
  mul(T2, Sc, Product).

area(Triangle, Area) :-
  heron_product(Triangle, Product),
  pow(Product, 0.5, Area).

heronProduct(Triangle, P) :- heron_product(Triangle, P).
status(Triangle, valid_survey_triangle) :- area(Triangle, A), gt(A, 0).
