% Catalan numbers by automatically tabled convolution.
%
% catalan(N,C) sums all splits of N-1 into left and right substructures.  The same
% Catalan values appear in binary tree shapes, parenthesizations, and polygon
% triangulations, shown here with small wrapper predicates.
materialize(catalan_answer, 2).


% C_0 = 1; higher values are computed by the convolution sum.
catalan(0, 1).
catalan(N, C) :-
  gt(N, 0),
  sub(N, 1, N1),
  sumall(Product,
    (between(0, N1, I),
     sub(N1, I, J),
     catalan(I, A),
     catalan(J, B),
     mul(A, B, Product)),
    C).

% An n-gon has C_(n-2) triangulations.
polygon_triangulations(Sides, Count) :-
  ge(Sides, 3),
  sub(Sides, 2, N),
  catalan(N, Count).

parenthesizations(Factors, Count) :-
  ge(Factors, 1),
  sub(Factors, 1, N),
  catalan(N, Count).

catalan_answer(catalan_12, C) :- catalan(12, C).
catalan_answer(triangulations_14_gon, Count) :- polygon_triangulations(14, Count).
catalan_answer(parenthesizations_13_factors, Count) :- parenthesizations(13, Count).
catalan_answer(first_ten_sum, Sum) :- sumall(C, (between(0, 9, N), catalan(N, C)), Sum).
