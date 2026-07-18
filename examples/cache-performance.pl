% Technology example: cache performance summary.
%
% A service has cache hits and misses with different response latencies. The
% rules compute hit rate and weighted average latency, then classify whether
% the cache is effective.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(hitRate, 2).
materialize(averageLatency_ms, 2).
materialize(status, 2).
materialize(reason, 2).

% cache_sample/5 contains hits, misses, and the two latency classes; threshold/3
% contains the operational targets used by the status rule.
cache_sample(api_cache, 8600.0, 1400.0, 5.0, 80.0).
threshold(api_cache, minimum_hit_rate, 0.80).
threshold(api_cache, maximum_average_latency_ms, 20.0).

% The rules compute total requests, hit rate, and weighted latency before
% applying both acceptance thresholds together.
total_requests(Cache, Total) :-
  cache_sample(Cache, Hits, Misses, _hitlatency, _misslatency),
  add(Hits, Misses, Total).

hit_rate(Cache, Rate) :-
  cache_sample(Cache, Hits, _misses, _hitlatency, _misslatency),
  total_requests(Cache, Total),
  div(Hits, Total, Rate).

average_latency(Cache, Average) :-
  cache_sample(Cache, Hits, Misses, Hitlatency, Misslatency),
  mul(Hits, Hitlatency, Hitcost),
  mul(Misses, Misslatency, Misscost),
  add(Hitcost, Misscost, Totalcost),
  total_requests(Cache, Total),
  div(Totalcost, Total, Average).

cache_effective(Cache) :-
  hit_rate(Cache, Rate),
  threshold(Cache, minimum_hit_rate, Minimumrate),
  gt(Rate, Minimumrate),
  average_latency(Cache, Average),
  threshold(Cache, maximum_average_latency_ms, Maximumlatency),
  lt(Average, Maximumlatency).

hitRate(Cache, Rate) :-
  hit_rate(Cache, Rate).

averageLatency_ms(Cache, Average) :-
  average_latency(Cache, Average).

status(Cache, cache_effective) :-
  cache_effective(Cache).

reason(Cache, "hit rate is above target and average latency is below limit") :-
  cache_effective(Cache).
