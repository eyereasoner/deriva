% BMI — ARC-style Body Mass Index example adapted from Eyeling.
%
% The example normalizes metric or US inputs, computes BMI, assigns the WHO
% adult category, derives a healthy-weight band for the same height, and emits
% an inspectable report plus independent checks.
%
% For reproducibility and documentation only; not medical advice.

% Editable metric input.
% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(unitSystem, 2).
materialize(weight, 2).
materialize(height, 2).
materialize(weightKg, 2).
materialize(heightM, 2).
materialize(units, 2).
materialize(heightSquared, 2).
materialize(bmi, 2).
materialize(bmiRoundedInt, 2).
materialize(healthyMinKg, 2).
materialize(healthyMaxKg, 2).
materialize(healthyMinKgRoundedInt, 2).
materialize(healthyMaxKgRoundedInt, 2).
materialize(category, 2).
materialize(heightCm, 2).
materialize(formula, 2).
materialize(calculation, 2).
materialize(categoryRule, 2).
materialize(unitsExplanation, 2).
materialize(c1, 2).
materialize(c2, 2).
materialize(c3, 2).
materialize(c4, 2).
materialize(c5, 2).
materialize(c6, 2).
materialize(c7, 2).
materialize(c8, 2).
materialize(c9, 2).
materialize(result, 2).
materialize(healthyWeightRangeKg, 2).
materialize(checkPassed, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
unitSystem(input, metric).
weight(input, 72.0).
height(input, 178.0).

% US alternative:
% unitSystem(input, us).
% weight(input, 158.73).
% height(input, 70.08).

% Normalization and BMI calculation.
% Derivation rules: each rule below contributes one logical step toward the displayed results.
weightKg(case, W) :-
  unitSystem(input, metric),
  weight(input, W).

heightM(case, M) :-
  unitSystem(input, metric),
  height(input, H),
  div(H, 100.0, M).

units(reason, "Inputs were already metric, so kilograms stay kilograms and centimeters are divided by 100 to obtain meters.") :-
  unitSystem(input, metric).

weightKg(case, Kg) :-
  unitSystem(input, us),
  weight(input, W),
  mul(W, 0.45359237, Kg).

heightM(case, M) :-
  unitSystem(input, us),
  height(input, H),
  mul(H, 0.0254, M).

units(reason, "US inputs were converted to SI units: pounds to kilograms and inches to meters.") :-
  unitSystem(input, us).

heightSquared(case, M2) :-
  heightM(case, M),
  mul(M, M, M2).

bmi(case, Bmi) :-
  weightKg(case, Kg),
  heightSquared(case, M2),
  div(Kg, M2, Bmi).

bmiRoundedInt(case, Bmiroundedint) :-
  bmi(case, Bmi),
  mul(Bmi, 100.0, Bmix100),
  rounded(Bmix100, Bmiroundedint).

healthyMinKg(case, Healthymin) :-
  heightSquared(case, M2),
  mul(18.5, M2, Healthymin).

healthyMaxKg(case, Healthymax) :-
  heightSquared(case, M2),
  mul(24.9, M2, Healthymax).

healthyMinKgRoundedInt(case, Minroundedint) :-
  healthyMinKg(case, Healthymin),
  mul(Healthymin, 10.0, Minx10),
  rounded(Minx10, Minroundedint).

healthyMaxKgRoundedInt(case, Maxroundedint) :-
  healthyMaxKg(case, Healthymax),
  mul(Healthymax, 10.0, Maxx10),
  rounded(Maxx10, Maxroundedint).

% WHO adult categories, using half-open intervals.
category(decision, "Underweight") :-
  bmi(case, Bmi),
  lt(Bmi, 18.5).

category(decision, "Normal") :-
  bmi(case, Bmi),
  ge(Bmi, 18.5),
  lt(Bmi, 25.0).

category(decision, "Overweight") :-
  bmi(case, Bmi),
  ge(Bmi, 25.0),
  lt(Bmi, 30.0).

category(decision, "Obesity I") :-
  bmi(case, Bmi),
  ge(Bmi, 30.0),
  lt(Bmi, 35.0).

category(decision, "Obesity II") :-
  bmi(case, Bmi),
  ge(Bmi, 35.0),
  lt(Bmi, 40.0).

category(decision, "Obesity III") :-
  bmi(case, Bmi),
  ge(Bmi, 40.0).

% Answer and reason why.
bmi(answer, 22.72) :-
  bmiRoundedInt(case, 2272).

category(answer, Category) :-
  category(decision, Category).

healthyMinKg(answer, 58.6) :-
  healthyMinKgRoundedInt(case, 586).

healthyMaxKg(answer, 78.9) :-
  healthyMaxKgRoundedInt(case, 789).

heightCm(answer, Cmrounded) :-
  heightM(case, M),
  mul(M, 100.0, Cm),
  rounded(Cm, Cmrounded).

formula(reason, "BMI is defined as weight in kilograms divided by height in meters squared.") :-
  bmi(case, _bmi).

calculation(reason, "The normalized weight and height were used to compute BMI, then the result was mapped to the WHO adult category table.") :-
  category(decision, _category).

categoryRule(reason, Category) :-
  category(decision, Category).

unitsExplanation(reason, Units) :-
  units(reason, Units).

% Independent checks.
c1(check, "OK - the input was normalized into positive SI values.") :-
  weightKg(case, Kg),
  heightM(case, M),
  gt(Kg, 0),
  gt(M, 0).

c2(check, "OK - height squared was reconstructed from the normalized height.") :-
  heightM(case, M),
  heightSquared(case, M2),
  mul(M, M, M2).

c3(check, "OK - the BMI value matches the BMI = kg / m² formula.") :-
  weightKg(case, Kg),
  heightSquared(case, M2),
  bmi(case, Bmi),
  div(Kg, M2, Bmi).

c4(check, "OK - a BMI of 18.49 stays below the normal-weight threshold.") :-
  lt(18.49, 18.5).

c5(check, "OK - the lower boundary is half-open: BMI 18.5 is classified as Normal.") :-
  ge(18.5, 18.5),
  lt(18.5, 25.0).

c6(check, "OK - BMI 25.0 starts the Overweight category.") :-
  ge(25.0, 25.0),
  lt(25.0, 30.0).

c7(check, "OK - BMI 30.0 starts the Obesity I category.") :-
  ge(30.0, 30.0),
  lt(30.0, 35.0).

c8(check, "OK - classification behavior is monotonic across representative BMI values.") :-
  ge(22.0, 18.5),
  lt(22.0, 25.0),
  ge(27.0, 25.0),
  lt(27.0, 30.0),
  ge(41.0, 40.0).

c9(check, "OK - the healthy-weight band was reconstructed from BMI 18.5 to 24.9 at the same height.") :-
  heightSquared(case, M2),
  healthyMinKg(case, Min),
  healthyMaxKg(case, Max),
  mul(18.5, M2, Min),
  mul(24.9, M2, Max).

% Derived report summary.  These relations are consequences of the calculation
% and checks, not pre-written report lines.
result(report, bmi(Bmi, Category)) :-
  bmi(answer, Bmi),
  category(answer, Category).

healthyWeightRangeKg(report, range(Min, Max)) :-
  healthyMinKg(answer, Min),
  healthyMaxKg(answer, Max).

heightCm(report, Height) :-
  heightCm(answer, Height).

checkPassed(report, Check) :-
  statement(check, Check, _message).
