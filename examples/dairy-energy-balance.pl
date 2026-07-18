% EYE-inspired dairy energy balance case study.
%
% cow(Cow, BodyWeightKg, MilkKgPerDay, RationEnergyMcalPerKgDM, IntakeKgDM)
% records a small herd.  Rules estimate maintenance demand, milk-production
% demand, ration supply, and the resulting energy-balance class.
materialize(energyBalance_Mcal, 2).
materialize(rationSupportedMilk_kg, 2).
materialize(status, 2).
materialize(reason, 2).
materialize(strongestDeficit, 2).

% Four cows cover negative, near-neutral, and positive balance cases.
cow(early_lactation, 650, 38, 6.4, 22).
cow(mid_lactation, 610, 24, 6.5, 26).
cow(late_lactation, 580, 16, 6.7, 25).
cow(grazing, 540, 18, 5.8, 21).

% Maintenance scales with body weight; milk requirement scales with daily milk.
maintenance(C, M) :-
  cow(C, Weight, _, _, _),
  mul(Weight, 0.08, M).

milk_requirement(C, R) :-
  cow(C, _, Milk, _, _),
  mul(Milk, 5.0, R).

ration_supply(C, S) :-
  cow(C, _, _, Density, Intake),
  mul(Density, Intake, S).

total_requirement(C, R) :-
  maintenance(C, M),
  milk_requirement(C, Milkr),
  add(M, Milkr, R).

% energy_balance/2 is intake minus maintenance and milk-production demand.
energy_balance(C, B) :-
  ration_supply(C, S),
  total_requirement(C, R),
  sub(S, R, B).

ration_supported_milk(C, Milk) :-
  ration_supply(C, S),
  maintenance(C, M),
  sub(S, M, Availableformilk),
  div(Availableformilk, 5.0, Milk).

status(C, negative_energy_balance) :-
  energy_balance(C, B),
  lt(B, -5.0).

status(C, near_neutral_energy_balance) :-
  energy_balance(C, B),
  ge(B, -5.0),
  le(B, 5.0).

status(C, positive_energy_balance) :-
  energy_balance(C, B),
  gt(B, 5.0).

energyBalance_Mcal(C, B) :- energy_balance(C, B).
rationSupportedMilk_kg(C, M) :- ration_supported_milk(C, M).
reason(dairy_energy_balance, "ration supply minus maintenance and milk energy requirement determines the class").
strongestDeficit(dairy_energy_balance, early_lactation) :-
  status(early_lactation, negative_energy_balance),
  status(late_lactation, positive_energy_balance).
