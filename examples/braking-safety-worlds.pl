% EYE reasoning-inspired example: braking safety in alternative worlds.
%
% Four simplified models classify the same road scenarios. The example is not a
% real safety calculator; it demonstrates rule-level model comparison.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(safeInWorld, 2).
materialize(riskyInWorld, 2).
materialize(status, 2).
materialize(reason, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
scenario(city_dry, 13.9, 0.8, 40.0).
scenario(highway_dry_short_gap, 27.8, 0.8, 60.0).
scenario(city_wet, 13.9, 0.4, 40.0).
scenario(city_ice, 13.9, 0.2, 30.0).

world(w0, "physics-based stopping distance with reaction time").
world(w1, "simplified braking-only rule without reaction time").
world(w2, "naive dry-road friction assumption").
world(w3, "cautious factor over the physics model").

% Derivation rules: each rule below contributes one logical step toward the displayed results.
stop_distance(Scenario, w0, Distance) :-
  scenario(Scenario, V, Mu, Avail),
  mul(V, 1.0, Reaction),
  pow(V, 2.0, V2),
  mul(Mu, 2.0, M2),
  mul(M2, 9.8, Denom),
  div(V2, Denom, Braking),
  add(Reaction, Braking, Distance).

stop_distance(Scenario, w1, Distance) :-
  scenario(Scenario, V, Mu, Avail),
  pow(V, 2.0, V2),
  mul(Mu, 2.0, M2),
  mul(M2, 10.0, Denom),
  div(V2, Denom, Distance).

stop_distance(Scenario, w2, Distance) :-
  scenario(Scenario, V, Mu, Avail),
  pow(V, 2.0, V2),
  div(V2, 14.0, Distance).

stop_distance(Scenario, w3, Distance) :-
  stop_distance(Scenario, w0, W0distance),
  mul(W0distance, 1.5, Distance).

safe_in_world(Scenario, World) :-
  scenario(Scenario, V, Mu, Avail),
  stop_distance(Scenario, World, Distance),
  le(Distance, Avail).

risky_in_world(Scenario, World) :-
  scenario(Scenario, V, Mu, Avail),
  stop_distance(Scenario, World, Distance),
  gt(Distance, Avail).

pattern_matches(report) :-
  safe_in_world(city_dry, w0), safe_in_world(city_dry, w1), safe_in_world(city_dry, w2), safe_in_world(city_dry, w3),
  risky_in_world(highway_dry_short_gap, w0), risky_in_world(highway_dry_short_gap, w3),
  safe_in_world(highway_dry_short_gap, w1), safe_in_world(highway_dry_short_gap, w2),
  safe_in_world(city_wet, w0), safe_in_world(city_wet, w1), safe_in_world(city_wet, w2), risky_in_world(city_wet, w3),
  risky_in_world(city_ice, w0), risky_in_world(city_ice, w1), risky_in_world(city_ice, w3), safe_in_world(city_ice, w2).

safeInWorld(Scenario, World) :- safe_in_world(Scenario, World).
riskyInWorld(Scenario, World) :- risky_in_world(Scenario, World).
status(braking_safety_worlds, expected_world_pattern) :- pattern_matches(report).
reason(braking_safety_worlds, "simplified and naive worlds can be optimistic while the cautious world tightens the reference model") :- pattern_matches(report).
