# The Art of Eyepl

## Relations, search, and explanations in a small logic language

Eyepl turns facts and rules into answers and inspectable proofs. This book is an
original introduction to the habits of logic programming: describe a world,
state the relationships that hold in it, and let unification and search connect
the two.

The name *Eyepl* combines *EYE* with *pl*: EYE-style reasoning in a compact,
Prolog-like notation. Eyepl inherits the relational outlook of Prolog, but it is
its own deliberately small language. It supplies facts, Horn clauses, terms,
lists, finite search, built-ins, automatic tabling, and proof output. It does not
attempt to reproduce the whole ISO Prolog environment.

All examples in this book are Eyepl programs. From a source checkout, replace
`eyepl` below with `node bin/eyepl.js` if the package is not linked.

```sh
npm install
node bin/eyepl.js examples/ancestor.pl
node bin/eyepl.js --proof examples/socrates.pl
```

The best way to read is at a terminal. Copy a program into a `.pl` file, ask a
slightly different question, and predict the answer before running it.

## Contents

### Part I — Relations

1. [A program is a little theory](#1-a-program-is-a-little-theory)
2. [Terms, variables, and substitution](#2-terms-variables-and-substitution)
3. [Rules and their two readings](#3-rules-and-their-two-readings)
4. [Recursion: describing reachability](#4-recursion-describing-reachability)
5. [Lists as relations](#5-lists-as-relations)

### Part II — Search

6. [Arithmetic and finite generation](#6-arithmetic-and-finite-generation)
7. [Failure, negation, and quantification](#7-failure-negation-and-quantification)
8. [Collecting and choosing answers](#8-collecting-and-choosing-answers)
9. [Structured data, strings, and contexts](#9-structured-data-strings-and-contexts)
10. [From puzzles to models](#10-from-puzzles-to-models)

### Part III — Trustworthy reasoning

11. [Queries, answers, and proofs](#11-queries-answers-and-proofs)
12. [Integrity constraints and inference fuses](#12-integrity-constraints-and-inference-fuses)
13. [Termination, tabling, and performance](#13-termination-tabling-and-performance)
14. [Knowledge engineering](#14-knowledge-engineering)
15. [RDF 1.2 as relational data](#15-rdf-12-as-relational-data)
16. [Embedding Eyepl](#16-embedding-eyepl)

### Appendices

- [A. Language summary](#appendix-a-language-summary)
- [B. Built-in predicates](#appendix-b-built-in-predicates)
- [C. Command-line reference](#appendix-c-command-line-reference)
- [D. Study paths and review](#appendix-d-study-paths-and-review)
- [E. Further examples](#appendix-e-further-examples)

---

# Part I — Relations

## 1. A program is a little theory

Logic programming begins with a change of emphasis. Instead of listing the
steps that calculate an answer, write sentences that are true in the problem
domain.

```eyepl
parent(ada, byron).
parent(byron, clara).
parent(clara, diego).
```

Each line is a **fact**. `parent/2` is a relation: the name is `parent` and the
arity is two. Arity matters. `parent/2` and `parent/3` are different predicates.

A **query declaration** selects the relation whose ground answers Eyepl prints:

```eyepl
child(Child, Parent) :- parent(Parent, Child).
query(child(X, Y)).
```

The answers are:

```eyepl
child(byron, ada).
child(clara, byron).
child(diego, clara).
```

The program did not copy values through named slots. It found substitutions
for `Child` and `Parent` that made the rule body true, then applied those same
substitutions to the head.

Before writing a relation, ask:

1. What does one ground fact mean as a sentence?
2. Which arguments are normally known when it is called?
3. Is the relation finite in that calling pattern?

For `parent(Parent, Child)`, a ground fact reads naturally from left to right.
Calling it with a parent enumerates children; calling it with a child enumerates
parents; calling it open enumerates the finite database. A good relation has a
clear sentence and useful modes.

Facts are data, not commands. Clause order can affect search order, but a fact
does not mean “do this now.”

**Exercise.** Add `grandparent/2` using two calls to `parent/2`. Query all
grandparents, then only the grandparents of `diego`.

## 2. Terms, variables, and substitution

Eyepl programs are built from terms:

- atom constants: `ada`, `accepted`, `'atom with spaces'`;
- strings: `"sensor too hot"`;
- numbers: `42`, `-7`, `3.14159`, `1.2e3`;
- variables: `X`, `Person`, `_temporary`;
- compound terms: `point(3, 4)`, `reading(temp, 91)`;
- lists: `[]`, `[red, green, blue]`, `[Head | Tail]`.

Plain atom constants begin with a lowercase ASCII letter. Variables begin with
an uppercase letter or underscore. The bare `_` is anonymous and every
occurrence is fresh. `_Name` is a named variable; repeated occurrences refer to
the same variable within its clause. Variables are local to a clause.

### Unification

Unification asks whether two terms can be made identical by binding variables.

```text
reading(Sensor, 91)
reading(temp, Value)
```

They unify with `Sensor = temp` and `Value = 91`. Structure must agree
recursively. `point(X, X)` unifies with `point(2, 2)` but not `point(2, 3)`.
Functor and arity must agree.

Eyepl exposes unification as `eq/2`:

```eyepl
same_shape(Pair) :- eq(Pair, pair(X, X)).

query(same_shape(pair(red, red))).
query(same_shape(pair(red, blue))).
```

Only the first query succeeds. `neq/2` succeeds when two resolved terms are not
structurally equal.

Compound terms retain domain structure:

```eyepl
measurement(battery_1, sample(17, volts(28.4), amps(12.1))).
route(a, d, path([a, b, d], cost(9))).
```

As a fact head, `measurement(...)` is an atomic formula. Nested terms are data.
The same surface form serves both roles; context decides which.

`ready` is an atom constant and `"ready"` is a string. Keep symbolic vocabulary
as atoms and human text as strings. Quoted atoms remain atoms:

```eyepl
label(sensor_1, "Cabin temperature").
web_name(sensor_1, '<https://example.org/sensor/1>').
```

**Exercise.** Write `diagonal/1`, which succeeds for `point(X, X)`. Then write
`same_ends/1` for a three-element list whose first and last values agree.

## 3. Rules and their two readings

A rule has a head and a comma-separated body:

```eyepl
eligible(Person) :-
  age(Person, Years),
  ge(Years, 18),
  registered(Person).
```

Read it declaratively: a person is eligible if the person has an age of at
least 18 and is registered. Read it operationally: to solve the head, solve the
body goals from left to right, carrying bindings into later goals.

Both readings matter. The declarative reading checks the model. The operational
reading helps make search finite and selective. Put a generator before a
built-in that needs its input:

```eyepl
adult(Person) :-
  age(Person, Years),
  ge(Years, 18).
```

Multiple clauses express alternatives:

```eyepl
can_enter(Person) :- staff(Person).
can_enter(Person) :- visitor(Person), escorted(Person).
```

Helper predicates reveal the model and improve explanations:

```eyepl
high_score(Case) :-
  score(Case, Score),
  threshold(Threshold),
  ge(Score, Threshold).

status(Case, accepted) :- high_score(Case).
reason(Case, "score meets threshold") :- high_score(Case).
```

## 4. Recursion: describing reachability

Recursive rules define an unbounded family of finite proofs. An ancestor is a
parent, or a parent of an ancestor:

```eyepl
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Z) :- parent(X, Y), ancestor(Y, Z).
query(ancestor(X, Y)).
```

The first clause is the base case. The second reduces an ancestor question to a
subquestion one edge farther through the graph. To design recursion, draw one
proof, find the repeated subquestion, and ensure some path reaches a base case.

Real graphs contain cycles. Naive depth-first recursion can revisit a call
forever. Eyepl analyzes predicate dependencies and automatically tables
suitable positive recursive groups. A table records answers for a recursive
call, iterates cyclic calls to a fixed point, and reuses results. Authors
describe `path/2`; the engine chooses the recursive strategy.

Tabling does not make every open relation finite. A rule that constructs
ever-larger terms can still produce infinitely many distinct calls or answers.
Keep the selected query and its generators finite.

A relation can construct a witness:

```eyepl
path(X, Y, [X, Y]) :- edge(X, Y).
path(X, Z, [X | Rest]) :-
  edge(X, Y),
  path(Y, Z, Rest).
```

On cyclic graphs, track visited vertices and use `not_member/2` to obtain finite
simple paths rather than arbitrary walks.

## 5. Lists as relations

`[a, b, c]` abbreviates nested cons cells. `[Head | Tail]` exposes one cell;
`[]` is empty.

```eyepl
first([Head | _], Head).

contains_item(X, [X | _]).
contains_item(X, [_ | Rest]) :- contains_item(X, Rest).

joins([], Ys, Ys).
joins([X | Xs], Ys, [X | Zs]) :- joins(Xs, Ys, Zs).
```

Different modes give `joins/3` different uses. It can construct a concatenated
list, enumerate every prefix/suffix split, or find a missing part. This is the
practical meaning of a relational definition.

Some algorithms carry explicit state through an accumulator:

```eyepl
reverse_acc(List, Reversed) :- reverse_go(List, [], Reversed).
reverse_go([], Acc, Acc).
reverse_go([X | Xs], Acc, Reversed) :-
  reverse_go(Xs, [X | Acc], Reversed).
```

No mutation occurs; every call receives a new term. Eyepl also includes
`member/2`, `append/3`, `select/3`, `nth0/3`, `reverse/2`, `length/2`,
`sort/2`, slicing helpers, and numeric summaries. Improper lists such as
`[a | Tail]` are valid terms, but operations requiring a proper finite list
fail unless the tail is `[]`.

---

# Part II — Search

## 6. Arithmetic and finite generation

Arithmetic is predicate-based. There is no `is` operator:

```eyepl
next(X, Y) :- add(X, 1, Y).
area_rectangle(W, H, Area) :- mul(W, H, Area).

hypotenuse(A, B, C) :-
  mul(A, A, A2),
  mul(B, B, B2),
  add(A2, B2, C2),
  sqrt(C2, C).
```

Inputs must be bound to suitable numbers before a numeric function runs.
Comparisons filter generated solutions:

```eyepl
safe_reading(Sensor, Value) :-
  reading(Sensor, Value),
  ge(Value, 0),
  le(Value, 80).
```

`between(Low, High, Value)` enumerates an inclusive integer range or checks an
already-bound value:

```eyepl
square(N, Square) :-
  between(1, 10, N),
  mul(N, N, Square).
```

Finite generators turn loops into searches. Recurrences need intended modes:

```eyepl
factorial(0, 1).
factorial(N, F) :-
  gt(N, 0),
  sub(N, 1, Previous),
  factorial(Previous, PF),
  mul(N, PF, F).

mode(factorial, 2, [in, out]).
```

Mode and determinism declarations are advisory facts for readers and tooling;
they do not direct the solver.

## 7. Failure, negation, and quantification

A goal fails when no clause or built-in proves it under current bindings.
Failure prunes that branch and search tries another choice.

`not(Goal)` succeeds when `Goal` has no solution:

```eyepl
allowed(User) :-
  user(User),
  not(blocked(User)).
```

This means “blocked cannot be proved from this program,” not classical
negation. Bind variables before negating. Putting `not(blocked(User))` before
`user(User)` asks whether there is no blocked user at all, not whether this
particular user is unblocked.

Negative dependencies should be stratified: compute a lower relation, then
negate it from a higher layer. Use `--warnings` to report negative recursion:

```sh
eyepl --warnings program.pl
```

`once(Goal)` keeps the first solution. `forall(Generator, Check)` succeeds when
every generated solution passes its check; an empty generator makes it true.

```eyepl
all_tests_pass(Suite) :-
  forall(test_in(Suite, Test), passed(Test)).
```

Use negation where the knowledge boundary is closed: a complete roster,
configuration, or finite result set. In open-world data, model explicit states
such as `confirmed_absent` instead of deriving absence from silence.

## 8. Collecting and choosing answers

Finite aggregation asks about a solution set:

```eyepl
findall(Template, Goal, List).
countall(Goal, Count).
sumall(Value, Goal, Sum).
```

```eyepl
outgoing_costs(Node, Costs) :-
  findall(Cost, edge(Node, _, Cost), Costs).

total_outgoing(Node, Total) :-
  sumall(Cost, edge(Node, _, Cost), Total).
```

`findall/3` returns `[]` for no answers; counts and sums return zero.

Optimization can retain only a best solution:

```eyepl
best_route(From, To, Route, Cost) :-
  aggregate_min(
    [CandidateCost, CandidateRoute],
    CandidateRoute,
    route(From, To, CandidateRoute, CandidateCost),
    [Cost, Route],
    Route
  ).
```

The key `[Cost, Route]` supplies deterministic tie-breaking through term order.
`aggregate_min/5` and `aggregate_max/5` fail when their goal has no answers.
An aggregate opens a smaller query scope inside the surrounding proof, and its
inner search must be finite.

## 9. Structured data, strings, and contexts

Term predicates decompose or construct general terms:

```eyepl
functor(Term, Name, Arity).
arg(Index, Term, Value).
compound_name_arguments(Term, Name, Arguments).
```

`arg/3` uses one-based indexes. Prefer direct pattern matching when the shape
is known; use inspection for generic transformations.

Text is best normalized at the model boundary:

```eyepl
normalized(Input, Words) :-
  trim(Input, Trimmed),
  lowercase(Trimmed, Lower),
  split(Lower, " ", Words).
```

Conversions include `number_string/2`, `atom_string/2`, and `term_string/2`.
Pattern operations include `contains/2`, `matches/2`, `not_matches/2`, and
named-capture `matches/3`. Turn text into structured terms early; keep central
rules relational.

Parenthesized comma terms can serve as context data:

```eyepl
message(event_17, (severity(high), source(sensor_3), reading(temp, 91))).

hot_event(Id) :-
  message(Id, Context),
  holds(Context, severity(high)),
  holds(Context, reading(temp, Value)),
  gt(Value, 80).
```

`holds/2` matches a member. `holds/3` exposes a member's name and argument list.
Context members remain quoted data; inspecting them does not assert them as
ambient facts.

## 10. From puzzles to models

A robust finite search has three layers: generate candidates, constrain them,
and present a concise answer.

```eyepl
color(red).
color(green).
color(blue).

coloring(A, B, C) :-
  color(A),
  color(B),
  neq(A, B),
  color(C),
  neq(B, C),
  neq(A, C).

answer(colors(A, B, C)) :- coloring(A, B, C).
query(answer(X)).
```

Place cheap, selective constraints as soon as their inputs are bound. For
state-transition problems, represent state and moves explicitly:

```eyepl
plan(State, State, _, []).
plan(State, Goal, Seen, [Move | Moves]) :-
  transition(State, Move, Next),
  not_member(Next, Seen),
  plan(Next, Goal, [Next | Seen], Moves).
```

The visited list makes a finite state space explicit. Eyepl is strongest when
the result is a logical consequence with a compact witness: a path, matching,
classification, schedule, proof, or bounded model. Mutable arrays and large
numerical kernels generally belong in a host, with Eyepl as the decision layer.

---

# Part III — Trustworthy reasoning

## 11. Queries, answers, and proofs

`query/1` is a host declaration selecting goals to run. Eyepl prints ground
answers, removes duplicates, and suppresses answers that merely repeat source
facts. Answers are not inserted back into the running program.

Use `--proof` or `-p` to add a machine-readable `why/2` fact after every answer:

```sh
eyepl --proof examples/socrates.pl
```

```eyepl
why(
  type(socrates, mortal),
  proof(
    goal(type(socrates, mortal)),
    by(rule("socrates.pl", clause(4))),
    bindings([binding("X", socrates)]),
    uses([
      proof(
        goal(type(socrates, man)),
        by(fact("socrates.pl", clause(3)))
      )
    ])
  )
).
```

Proof output is valid Eyepl input:

```sh
eyepl --proof examples/socrates.pl > socrates.why.pl
```

A second program can query `why/2`. Read a proof as an argument. If it contains
irrelevant detours, improve the helpers. If a key premise is hidden inside an
opaque value, model it as a fact. Designing for a good explanation often
produces a better theory.

## 12. Integrity constraints and inference fuses

A rule headed by `false` is an **inference fuse**:

```eyepl
false :-
  probability(Disease, Probability),
  gt(Probability, 1).
```

Eyepl checks fuses before queries. The first match aborts the CLI with exit code
`65` and reports the rule and matched instance. A bare `false.` is unconditional.

```eyepl
false :-
  assigned(Person, Role),
  incompatible_roles(Role, Other),
  assigned(Person, Other).
```

The logical reading is that no acceptable model contains this combination.
Fuses express domain contradictions, not resource bounds or search limits.

## 13. Termination, tabling, and performance

Declarative clarity and operational care reinforce each other. Bind selective
arguments early, keep generators finite, and make decreasing structure visible.

Ordinary goals use indexed depth-first resolution. Positive recursive groups
are tabled automatically. Bound recursive calls reuse answers and cyclic calls
iterate toward a fixed point. Fully open or structurally unbounded calls may
retain ordinary resolution. Recursive components with negative dependencies
are not positive fixed points.

Authors choose query modes, finite domains, visited-state representations,
negation strata, and witness size. They normally do not choose the engine's
search strategy.

Inspect counters without changing answer output:

```sh
eyepl --stats examples/observability-log-correlation.pl
```

Common sources of nontermination are recursive calls made before constraints,
ever-growing terms, infinite open mathematical queries, negative cycles, and
path enumeration without a visited set. Repair the model by strengthening the
query, adding a finite domain, tracking states, or exposing a decreasing
argument.

## 14. Knowledge engineering

A maintainable theory separates:

- source facts: measurements, records, and asserted relationships;
- helpers: normalization, classifications, and reachability;
- decisions: `status/2`, `action/2`, `risk/2`, and `reason/2`;
- integrity constraints: rules headed by `false`;
- outputs: focused `query/1` declarations.

Prefer positive domain concepts. Use negation only across a closed boundary.
Represent confidence, alternative worlds, and provenance explicitly rather
than hiding them in rule order.

An evidence-backed diagnosis can separate physics from policy:

```eyepl
heating(Battery, Watts) :-
  current(Battery, Amps),
  resistance(Battery, Ohms),
  mul(Amps, Amps, I2),
  mul(I2, Ohms, Watts).

thermal_warning(Battery) :-
  heating(Battery, Watts),
  heating_limit(Limit),
  gt(Watts, Limit),
  temperature(Battery, Celsius),
  temperature_limit(TLimit),
  gt(Celsius, TLimit).

action(Battery, isolate_and_cool) :- thermal_warning(Battery).
```

Physics, limits, redundant sensing, and policy become distinct proof steps. See
`examples/spacecraft-battery-diagnosis.pl` for a complete case.

Test theories with successful derivations, expected failures, boundary values,
duplicate paths, contradictory inputs, and proof premises. The repository's
conformance cases, example goldens, and proof goldens demonstrate these levels.

## 15. RDF 1.2 as relational data

Eyepl's core is RDF-agnostic. Adapter tools translate datasets into ordinary
`rdf(Subject, Predicate, Object, Graph)` facts:

```sh
node tools/rdf-to-eyepl.mjs --rules rules.pl data.trig -o program.pl
eyepl program.pl > derived.pl
node tools/eyepl-to-rdf.mjs derived.pl -o derived.nq
```

Supported inputs include RDF 1.2 Turtle, TriG, N-Triples, N-Quads, RDF/XML,
JSON-LD, RDFa, Microdata, Notation3, and SHACL Compact Syntax. For stdin, supply
`--format`; use `--base` for relative IRIs.

| RDF value | Eyepl term |
| --- | --- |
| IRI | `iri(Value)` |
| Blank node | `bnode(Scope, Label)` |
| Typed literal | `literal(Value, datatype(IRI))` |
| Language string | `literal(Value, lang(Language))` |
| Directional string | `literal(Value, lang(Language, ltr))` or `lang(Language, rtl)` |
| RDF 1.2 triple term | `triple(Subject, Predicate, Object)` |
| Default graph | `default_graph` |

Scopes distinguish blank nodes from different documents. Triple terms may
nest, and named graphs occupy the fourth argument.

```eyepl
rdf(S, iri("https://example/ancestor"), O, G) :-
  rdf(S, iri("https://example/parent"), O, G).
```

By default, source quads support inference but are not copied to output. Pass
`--include-source` to retain them. Output is RDF 1.2 N-Quads. See
[`tools/README.md`](tools/README.md) for the full adapter contract.

## 16. Embedding Eyepl

The JavaScript API exposes a convenience runner and lower-level types:

```js
import { run, Program, Solver } from 'eyepl';

const result = run(`
query(answer(X)).
answer(ok) :- eq(ok, ok).
`);
console.log(result.stdout);
```

Fired fuses throw `InferenceFuseError` with code
`INFERENCE_FUSE_EXIT_CODE`. Programs expose stratification diagnostics through
`stratifiedNegation`, `negationStratificationErrors`, and
`assertStratifiedNegation()`.

Treat remote source as executable logic. Although Eyepl has no arbitrary host
call primitive, search can consume CPU and memory. Embedders should impose
appropriate depth, solution, input-size, and time limits.

---

# Appendix A. Language summary

Eyepl source is UTF-8. `%` starts a line comment. Plain atoms begin with a
lowercase ASCII letter. Variables begin with uppercase or underscore. The bare
`_` is fresh each time. Single quotes delimit quoted atoms; double quotes
delimit strings. Integers, decimals, and scientific notation are accepted.

Graphic atoms may contain `#$&*+-/<=>@^~\`. Colon names and unquoted
angle-bracket IRIs are not syntax; quote names containing such punctuation.

```text
program      ::= { clause }
clause       ::= head "." | head ":-" goals "."
goals        ::= term { "," term }
term         ::= variable | atom | string | number
               | atom "(" term { "," term } ")"
               | "[" [ term { "," term } [ "|" term ] ] "]"
               | "(" term { "," term } ")"
```

Zero-arity compounds such as `ready()` are unsupported; use `ready`. Every
clause ends in a period. There are no user-defined operators.

The pure definite-clause fragment has a Herbrand reading: ground terms denote
themselves, predicates denote sets of ground atomic formulas, variables have
clause scope, and unification is structural. Execution is goal-directed rather
than complete bottom-up saturation. `not/1` is negation as failure.

Eyepl deliberately omits cut, operator declarations, modules, dynamic database
updates, DCGs, and a complete ISO Prolog library.

# Appendix B. Built-in predicates

The implementation registers 80 name/arity entries across 78 names. The
conformance corpus under `test/conformance/cases/` is the precise executable
contract.

| Family | Built-ins |
| --- | --- |
| Core and dates | `eq/2`, `neq/2`, `local_time/1`, `difference/3` |
| Unary arithmetic | `neg/2`, `abs/2`, `sin/2`, `cos/2`, `tan/2`, `asin/2`, `acos/2`, `sqrt/2`, `floor/2`, `ceiling/2`, `trunc/2`, `rounded/2`, `exp/2`, `log/2` |
| Binary arithmetic | `add/3`, `sub/3`, `mul/3`, `div/3`, `mod/3`, `min/3`, `max/3`, `pow/3`, `atan2/3` |
| Compare/generate | `lt/2`, `gt/2`, `le/2`, `ge/2`, `between/3`, `smallest_divisor_from/3` |
| Strings | `str_concat/3`, `contains/2`, `matches/2`, `matches/3`, `not_matches/2`, `split/3`, `join/3`, `substring/4`, `replace/4`, `lowercase/2`, `uppercase/2`, `trim/2`, `number_string/2`, `atom_string/2`, `term_string/2` |
| Lists | `append/3`, `nth0/3`, `set_nth0/4`, `head/2`, `rest/2`, `last/2`, `take/3`, `drop/3`, `slice/4`, `member/2`, `select/3`, `not_member/2`, `reverse/2`, `length/2`, `sum_list/2`, `min_list/2`, `max_list/2`, `list_to_set/2`, `sort/2` |
| Aggregation | `findall/3`, `countall/2`, `sumall/3`, `aggregate_min/5`, `aggregate_max/5` |
| Control | `not/1`, `once/1`, `forall/2` |
| Context/terms | `holds/2`, `holds/3`, `functor/3`, `arg/3`, `compound_name_arguments/3` |

`nth0/3` uses zero-based indexes; `arg/3` uses one-based indexes. `sort/2`
deduplicates. Invalid numeric domains fail. Aggregation requires finite search.

# Appendix C. Command-line reference

```text
eyepl [options] [file-or-url.pl|- ...]
```

| Option | Meaning |
| --- | --- |
| `-h`, `--help` | Show usage |
| `-p`, `--proof` | Print `why/2` explanations |
| `-s`, `--stats` | Print solver counters to stderr |
| `-v`, `--version` | Print the package version |
| `-w`, `--warnings` | Print non-fatal portability warnings |
| `--` | Treat following arguments as inputs |

Inputs may be local files, HTTP(S) URLs, or one `-` for stdin. With no input,
stdin is used.

# Appendix D. Study paths and review

For a first week, run `socrates.pl` and `ancestor.pl`, rewrite them from memory,
inspect their proofs, learn `member/2`, `append/3`, and `select/3`, solve one
finite puzzle, and add one inference fuse.

Modelers should study `access-control-policy.pl`,
`clinical-trial-screening.pl`, `gdpr-compliance.pl`, and
`trust-flow-provenance-threshold.pl`. Identify facts, derived concepts,
decisions, closed-world assumptions, and proof premises.

Algorithm students should study `graph-reachability.pl`,
`dijkstra-risk-path.pl`, `stable-marriage.pl`, `sat-solver-dpll.pl`, and
`type-inference.pl`. For each, identify the finite domain, branching relation,
pruning goals, witness, and termination argument.

Review questions:

1. What distinguishes an atom constant from an atomic formula?
2. Why can one append relation construct lists and split them?
3. When does goal order affect performance but not declarative meaning?
4. Why should variables usually be bound before `not/1`?
5. What does automatic tabling solve, and what does it not solve?
6. Why is proof output useful when the answer is already known?
7. When is a fuse preferable to an ordinary `invalid/1` conclusion?
8. What does an explicit RDF adapter preserve about the core language?

# Appendix E. Further examples

The `examples/` directory is executable documentation. Runnable examples have
golden answers in `examples/output/`; selected programs have proof goldens in
`examples/proof/`.

| Theme | Examples |
| --- | --- |
| Core logic | `socrates.pl`, `ancestor.pl`, `graph-reachability.pl` |
| Lists/search | `list-collection.pl`, `n-queens-8.pl`, `zebra.pl` |
| Mathematics | `fibonacci.pl`, `peano-arithmetic.pl`, `stirling-bell-numbers.pl` |
| Planning | `route-planning.pl`, `blocks-world-planning.pl`, `wolf-goat-cabbage.pl` |
| Policy | `access-control-policy.pl`, `gdpr-compliance.pl`, `workplace-compliance.pl` |
| Science | `beam-deflection.pl`, `competitive-enzyme-kinetics.pl`, `spacecraft-battery-diagnosis.pl` |
| Program analysis | `abstract-interpretation.pl`, `pointer-analysis.pl`, `type-inference.pl` |
| Symbolic systems | `symbolic-derivative.pl`, `knuth-bendix-completion.pl`, `equality-saturation.pl` |
| RDF 1.2 | `rdf12-triple-term.pl`, `rdf12-trig-named-graph.pl`, `rdf12-directional-language.pl` |

Run the complete executable corpus with `npm test`.

The aim of Eyepl is not to make every difficult problem easy. It is to keep the
theory visible while the machine searches it: facts you can inspect, rules you
can discuss, answers you can test, and proofs you can carry forward as data.
