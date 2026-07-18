% Polygon area by the shoelace formula.
%
% The input polygon is the same closed polygon shape used by the source example:
% the final point repeats the first point.  Each recursive step consumes one
% adjacent pair and contributes `(x1*y2 - y1*x2) / 2` to the oriented area.

materialize(polygon_area, 2).

sample_polygon([[3, 2], [6, 2], [7, 6], [4, 6], [5, 5], [5, 3], [3, 2]]).

area([_point], 0).
area([[A, B], [C, D]|Rest], Total) :-
  area([[C, D]|Rest], Subtotal),
  mul(A, D, Ad),
  mul(B, C, Bc),
  sub(Ad, Bc, Cross),
  div(Cross, 2.0, Half),
  add(Half, Subtotal, Total).

polygon_area(sample, Area) :-
  sample_polygon(Points),
  area(Points, Area).
