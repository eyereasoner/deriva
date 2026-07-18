% Math example: least-squares linear regression.
%
% The rules reduce a list of points to sufficient statistics, then derive the
% fitted slope, intercept, and coefficient of determination R^2.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
%
% Accumulating sufficient statistics keeps the regression formulas compact and
% makes the proof show the same intermediate values a hand calculation would use.
materialize(slope, 2).
materialize(intercept, 2).
materialize(rSquared, 2).
materialize(status, 2).
materialize(reason, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
dataset(regression1, [point(1.0, 2.0), point(2.0, 3.0), point(3.0, 5.0), point(4.0, 4.0)]).
threshold(regression1, minimum_r_squared, 0.60).

% stats/7 folds points into N, Σx, Σy, Σx², Σxy, and Σy².
stats([], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0).
% Derivation rules: each rule below contributes one logical step toward the displayed results.
stats([point(X, Y)|Rest], N, Sumx, Sumy, Sumxx, Sumxy, Sumyy) :-
  stats(Rest, N0, Sumx0, Sumy0, Sumxx0, Sumxy0, Sumyy0),
  add(N0, 1.0, N),
  add(Sumx0, X, Sumx),
  add(Sumy0, Y, Sumy),
  mul(X, X, Xx),
  add(Sumxx0, Xx, Sumxx),
  mul(X, Y, Xy),
  add(Sumxy0, Xy, Sumxy),
  mul(Y, Y, Yy),
  add(Sumyy0, Yy, Sumyy).

sufficient_statistics(Data, N, Sumx, Sumy, Sumxx, Sumxy, Sumyy) :-
  dataset(Data, Points),
  stats(Points, N, Sumx, Sumy, Sumxx, Sumxy, Sumyy).

slope(Data, Slope) :-
  sufficient_statistics(Data, N, Sumx, Sumy, Sumxx, Sumxy, _sumyy),
  mul(N, Sumxy, Nsumxy),
  mul(Sumx, Sumy, Sumxsumy),
  sub(Nsumxy, Sumxsumy, Numerator),
  mul(N, Sumxx, Nsumxx),
  mul(Sumx, Sumx, Sumxsquared),
  sub(Nsumxx, Sumxsquared, Denominator),
  div(Numerator, Denominator, Slope).

intercept(Data, Intercept) :-
  sufficient_statistics(Data, N, Sumx, Sumy, _sumxx, _sumxy, _sumyy),
  slope(Data, Slope),
  mul(Slope, Sumx, Slopesumx),
  sub(Sumy, Slopesumx, Numerator),
  div(Numerator, N, Intercept).

r_squared(Data, R2) :-
  sufficient_statistics(Data, N, Sumx, Sumy, Sumxx, Sumxy, Sumyy),
  mul(N, Sumxy, Nsumxy),
  mul(Sumx, Sumy, Sumxsumy),
  sub(Nsumxy, Sumxsumy, Numeratorbase),
  pow(Numeratorbase, 2.0, Numerator),
  mul(N, Sumxx, Nsumxx),
  mul(Sumx, Sumx, Sumxsquared),
  sub(Nsumxx, Sumxsquared, Xspread),
  mul(N, Sumyy, Nsumyy),
  mul(Sumy, Sumy, Sumysquared),
  sub(Nsumyy, Sumysquared, Yspread),
  mul(Xspread, Yspread, Denominator),
  div(Numerator, Denominator, R2).

accepted_fit(Data) :-
  r_squared(Data, R2),
  threshold(Data, minimum_r_squared, Minimum),
  ge(R2, Minimum).



rSquared(Data, R2) :-
  r_squared(Data, R2).

status(Data, accepted_linear_fit) :-
  accepted_fit(Data).

reason(Data, "R squared meets the minimum explanatory-power threshold") :-
  accepted_fit(Data).
