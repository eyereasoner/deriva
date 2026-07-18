% Reference 7.3, 9.2, 9.5: finite arithmetic recursion works with generated ranges.
materialize(answer, 2).
even(0).
even(N) :- gt(N, 0), sub(N, 1, M), odd(M).
odd(N) :- gt(N, 0), sub(N, 1, M), even(M).
answer(even, N) :- between(0, 6, N), even(N).
answer(odd, N) :- between(0, 6, N), odd(N).
