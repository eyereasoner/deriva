% Control Systems example, adapted from Eyelet's input/control-system.pl.
%
% The example combines measurements, observations, targets, logarithmic
% feedforward compensation, square-root normalization, and nonlinear feedback.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
%
% Each derived quantity is represented as its own predicate rather than a single
% formula blob, making the proof trace useful for debugging a failed actuator
% normalization or control-signal calculation.
materialize(controlSignal, 2).
materialize(status, 2).
materialize(normalizedMeasurement, 2).
materialize(log10, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
measurement(input1, [6, 11]).
measurement(disturbance2, [45, 39]).
measurement(input2, true).
measurement(input3, 56967).
measurement(disturbance1, 35766).
measurement(output2, 24).

observation(state1, 80).
observation(state2, false).
observation(state3, 22).

target(output2, 29).

% Derivation rules: each rule below contributes one logical step toward the displayed results.
measurement_normalized(I, M) :-
  measurement(I, [M1, M2]),
  lt(M1, M2),
  sub(M2, M1, Delta),
  pow(Delta, 0.5, M).

measurement_normalized(I, M1) :-
  measurement(I, [M1, M2]),
  ge(M1, M2).

log10(Value, Result) :-
  log(Value, Naturallog),
  log(10, Naturallog10),
  div(Naturallog, Naturallog10, Result).

control(actuator1, C) :-
  measurement_normalized(input1, M1),
  measurement(input2, true),
  measurement(disturbance1, D1),
  mul(M1, 19.6, Proportional),
  log10(D1, Compensation),
  sub(Proportional, Compensation, C).

control(actuator2, C) :-
  observation(state3, P3),
  measurement(output2, M4),
  target(output2, T2),
  sub(T2, M4, Error),
  sub(P3, M4, Differentialerror),
  mul(5.8, Error, Proportional),
  div(7.3, Error, Nonlinearfactor),
  mul(Nonlinearfactor, Differentialerror, Differential),
  add(Proportional, Differential, C).

controlSignal(Actuator, C) :-
  control(Actuator, C).

status(Actuator, active) :-
  control(Actuator, _c).

normalizedMeasurement(input1, M) :-
  measurement_normalized(input1, M).

log10(disturbance1, C) :-
  measurement(disturbance1, D),
  log10(D, C).
