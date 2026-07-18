% socket-age.pl
%
% A small runnable via Socket example for age reasoning.
%
% The socket facts are ordinary via data. They document the semantic
% openings that this rule module expects:
%
%   - a patient registry that provides birthDay/2
%   - a policy source that provides duration/2
%   - a clock source that provides today/1
%
% The plug facts say which concrete providers are connected.
%
% Run:
%   via socket-age.pl

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(ageAbove, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
socket(patient_registry, provides(birthDay_2)).
socket(policy_source, provides(duration_2)).
socket(clock_source, provides(today_1)).

plug(test_patients, patient_registry).
plug(test_policy, policy_source).
plug(test_clock, clock_source).

birthDay(patH, "1944-08-21").
duration(check, "P80Y").
today("2026-05-30").

% Derivation rules: each rule below contributes one logical step toward the displayed results.
ageAbove(S, A) :-
    birthDay(S, B),
    duration(check, A),
    today(D),
    difference(D, B, F),
    gt(F, A).
