% Population statistics for a small numeric sample.
%
% The sample is the textbook data set [2,4,4,4,5,5,7,9], whose population
% mean is 5, variance is 4, and standard deviation is 2.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(count, 2).
materialize(mean, 2).
materialize(populationVariance, 2).
materialize(populationStddev, 2).

% The sample is one list fact, which lets recursive list folds demonstrate
% aggregation without introducing a separate row relation.
sample(scores, [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]).

sum([], 0.0).
% sum/2 and squared_error_sum/3 are recursive folds; the public relations then
% derive count, mean, population variance, and standard deviation.
sum([X|Xs], Total) :-
  sum(Xs, Rest),
  add(X, Rest, Total).

mean(Name, Mean) :-
  sample(Name, Values),
  sum(Values, Total),
  length(Values, Count),
  div(Total, Count, Mean).

squared_error_sum([], _mean, 0.0).
squared_error_sum([X|Xs], Mean, Total) :-
  sub(X, Mean, Delta),
  pow(Delta, 2.0, Squared),
  squared_error_sum(Xs, Mean, Rest),
  add(Squared, Rest, Total).

population_variance(Name, Variance) :-
  sample(Name, Values),
  mean(Name, Mean),
  squared_error_sum(Values, Mean, Sumsquarederrors),
  length(Values, Count),
  div(Sumsquarederrors, Count, Variance).

population_stddev(Name, Stddev) :-
  population_variance(Name, Variance),
  pow(Variance, 0.5, Stddev).

count(Name, Count) :-
  sample(Name, Values),
  length(Values, Count).


populationVariance(Name, Variance) :-
  population_variance(Name, Variance).

populationStddev(Name, Stddev) :-
  population_stddev(Name, Stddev).
