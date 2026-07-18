% Vector dot product, Euclidean norm, and cosine similarity.
%
% Recursive list folds compute the dot product and squared-length sums.  The
% public cosineSimilarity/2 report then combines those folds as
% dot(A,B)/(norm(A)*norm(B)) for a named vector pair.
%
% The example keeps vectors as ordinary Via lists, so it doubles as a compact
% demonstration of numeric recursion over list structure.

materialize(dotProduct, 2).
materialize(normA, 2).
materialize(normB, 2).
materialize(cosineSimilarity, 2).

% Two named vectors form the single cosine-similarity case.
vector(pair1, a, [1.0, 2.0, 3.0]).
vector(pair1, b, [4.0, -5.0, 6.0]).

% Recursive list folds compute dot products and sums of squares.
dot([], [], 0.0).
dot([A|As], [B|Bs], Dot) :-
  mul(A, B, Product),
  dot(As, Bs, Rest),
  add(Product, Rest, Dot).

sum_squares([], 0.0).
sum_squares([X|Xs], Total) :-
  pow(X, 2.0, Squared),
  sum_squares(Xs, Rest),
  add(Squared, Rest, Total).

norm(Vector, Norm) :-
  sum_squares(Vector, Sumsquares),
  pow(Sumsquares, 0.5, Norm).

% cosine = dot(A,B) / (norm(A) * norm(B)).
cosine_similarity(Case, Similarity) :-
  vector(Case, a, A),
  vector(Case, b, B),
  dot(A, B, Dot),
  norm(A, Norma),
  norm(B, Normb),
  mul(Norma, Normb, Denominator),
  div(Dot, Denominator, Similarity).

dotProduct(Case, Dot) :-
  vector(Case, a, A),
  vector(Case, b, B),
  dot(A, B, Dot).

normA(Case, Norma) :-
  vector(Case, a, A),
  norm(A, Norma).

normB(Case, Normb) :-
  vector(Case, b, B),
  norm(B, Normb).

cosineSimilarity(Case, Similarity) :-
  cosine_similarity(Case, Similarity).
