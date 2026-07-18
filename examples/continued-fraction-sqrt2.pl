% Convergents of sqrt(2) by automatically tabled recurrence.
%
% conv(N, P, Q) gives the Nth numerator/denominator pair for [1; 2, 2, ...].
% Because each convergent depends on the previous two, memoization avoids the
% exponential recomputation that the direct Horn-clause recurrence would have.
% pell_error/2 connects the approximation sequence with P^2 - 2Q^2 = +/-1.
materialize(convergent_answer, 2).


% Base convergents are 1/1 and 3/2.
conv(0, 1, 1).
conv(1, 3, 2).
conv(N, P, Q) :-
  gt(N, 1),
  sub(N, 1, N1),
  sub(N, 2, N2),
  conv(N1, P1, Q1),
  conv(N2, P2, Q2),
  mul(2, P1, Twicep1),
  add(Twicep1, P2, P),
  mul(2, Q1, Twiceq1),
  add(Twiceq1, Q2, Q).

% The signed error alternates between +1 and -1 for these convergents.
pell_error(N, Error) :-
  conv(N, P, Q),
  mul(P, P, P2),
  mul(Q, Q, Q2),
  mul(2, Q2, Twiceq2),
  sub(P2, Twiceq2, Error).

convergent_answer(convergent_10, fraction(P, Q)) :- conv(10, P, Q).
convergent_answer(convergent_15, fraction(P, Q)) :- conv(15, P, Q).
convergent_answer(pell_error_15, Error) :- pell_error(15, Error).
convergent_answer(numerator_sum_0_to_10, Sum) :- sumall(P, (between(0, 10, N), conv(N, P, _q)), Sum).
