% EYE-inspired field nitrogen balance case study.
%
% field(Field, SoilN, FertilizerN, LossFraction, CropDemandN) stores a compact
% nutrient budget.  Rules derive retained nitrogen, deficit, surplus, and a
% leaching-risk index before assigning each field a status.
materialize(availableN_kg_ha, 2).
materialize(deficitN_kg_ha, 2).
materialize(surplusN_kg_ha, 2).
materialize(leachingIndex, 2).
materialize(status, 2).
materialize(highestLeachingRisk, 2).
materialize(reason, 2).

% The four fields cover under-supplied, balanced, and over-supplied scenarios
% with different loss fractions so leaching risk is not just total surplus.
field(low_input, 25, 40, 0.10, 110).
field(balanced_loam, 45, 80, 0.12, 110).
field(sandy_high, 30, 150, 0.35, 105).
field(clay_surplus, 70, 90, 0.08, 120).

% total_n/2 and available_n/2 build the nutrient budget; surplus/deficit and
% leaching rules then explain the resulting field status.
total_n(F, Total) :-
  field(F, Soil, Fert, _, _),
  add(Soil, Fert, Total).

available_n(F, Avail) :-
  total_n(F, Total),
  field(F, _, _, Loss, _),
  sub(1.0, Loss, Retained),
  mul(Total, Retained, Avail).

% surplus_n/2 and deficit_n/2 split the signed balance into reportable quantities.
surplus_n(F, Surplus) :-
  available_n(F, Avail),
  field(F, _, _, _, Demand),
  gt(Avail, Demand),
  sub(Avail, Demand, Surplus).

surplus_n(F, 0.0) :-
  available_n(F, Avail),
  field(F, _, _, _, Demand),
  le(Avail, Demand).

deficit_n(F, Deficit) :-
  available_n(F, Avail),
  field(F, _, _, _, Demand),
  lt(Avail, Demand),
  sub(Demand, Avail, Deficit).

deficit_n(F, 0.0) :-
  available_n(F, Avail),
  field(F, _, _, _, Demand),
  ge(Avail, Demand).

leaching_index(F, Index) :-
  surplus_n(F, Surplus),
  field(F, _, _, Loss, _),
  mul(Surplus, Loss, Index).

status(F, under_supplied) :- deficit_n(F, D), gt(D, 10.0).
status(F, balanced) :- deficit_n(F, D), surplus_n(F, S), le(D, 10.0), le(S, 10.0).
status(F, over_supplied) :- surplus_n(F, S), gt(S, 10.0).

availableN_kg_ha(F, A) :- available_n(F, A).
deficitN_kg_ha(F, D) :- deficit_n(F, D).
surplusN_kg_ha(F, S) :- surplus_n(F, S).
leachingIndex(F, I) :- leaching_index(F, I).
highestLeachingRisk(field_nitrogen_balance, sandy_high) :-
  leaching_index(sandy_high, Sandy),
  leaching_index(clay_surplus, Clay),
  gt(Sandy, Clay).
reason(field_nitrogen_balance, "available nitrogen is total input retained after losses compared with crop demand").
