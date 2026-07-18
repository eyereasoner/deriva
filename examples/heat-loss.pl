% Engineering example: one-dimensional conductive heat loss through a wall.
%
% Thermal resistance is L/(k*A), and heat loss is DeltaT/R.  The facts store wall
% properties as a small attribute table, while rules derive temperature
% difference, resistance, heat loss, and a qualitative status.
%
% Keeping each physical quantity as its own relation makes the proof explanation
% read like a worked calculation.
materialize(type, 2).
materialize(temperatureDifference_K, 2).
materialize(thermalResistance_K_W, 2).
materialize(heatLoss_W, 2).
materialize(status, 2).

% Wall properties are stored as key/value facts: conductivity, area, thickness,
% and inside/outside temperatures.
wall(wall1, conductivity_W_mK, 0.8).
wall(wall1, area_m2, 12.0).
wall(wall1, thickness_m, 0.2).
wall(wall1, indoor_C, 21.0).
wall(wall1, outdoor_C, -4.0).

% The model first derives the temperature difference and thermal resistance,
% then divides DeltaT by resistance to classify the heat loss.
temperature_difference(Wall, Deltat) :-
  wall(Wall, indoor_C, Indoor),
  wall(Wall, outdoor_C, Outdoor),
  sub(Indoor, Outdoor, Deltat).

thermal_resistance(Wall, Resistance) :-
  wall(Wall, thickness_m, Thickness),
  wall(Wall, conductivity_W_mK, Conductivity),
  wall(Wall, area_m2, Area),
  mul(Conductivity, Area, Conductance),
  div(Thickness, Conductance, Resistance).

heat_loss(Wall, Heatloss) :-
  temperature_difference(Wall, Deltat),
  thermal_resistance(Wall, Resistance),
  div(Deltat, Resistance, Heatloss).

type(Wall, conduction_heat_loss) :-
  wall(Wall, thickness_m, _thickness).

temperatureDifference_K(Wall, Deltat) :-
  temperature_difference(Wall, Deltat).

thermalResistance_K_W(Wall, Resistance) :-
  thermal_resistance(Wall, Resistance).

heatLoss_W(Wall, Heatloss) :-
  heat_loss(Wall, Heatloss).

status(Wall, high_heat_loss) :-
  heat_loss(Wall, Heatloss),
  gt(Heatloss, 1000.0).
