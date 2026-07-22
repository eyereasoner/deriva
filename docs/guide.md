# Eyepl Guide

This guide introduces Eyepl, a small Horn-clause language and engine whose source syntax is Prolog-like but deliberately its own compact language for facts, rules, goals, answers, and proofs. Eyepl works over ordinary terms, lists, arithmetic, strings, and finite search. Run it with the `eyepl` CLI, or use `node bin/eyepl.js` when working directly from a source checkout.

This documentation uses **Eyepl** for the project, language, and engine, and
`eyepl` for the npm package and CLI command.

Programs write relations directly, for example `ancestor(pat, emma)` or `status(case1, accepted)`. Web identifiers can be written as ordinary quoted atoms that include angle brackets, for example `'<https://schema.org/name>'`, when a program needs explicit IRI-shaped names without prefix declarations. Eyepl output is ordinary Eyepl syntax: by default, the CLI materializes selected answer facts and prints those facts only. Pass `--proof` (or `-p`) when you also want each answer followed by a `why/2` explanation fact that records the proof. Programs may add `materialize/2` declarations such as `materialize(answer, 2).` to focus output on selected predicates.

Execution is automatically hybrid. Ordinary predicates use indexed
goal-directed resolution, while dependency analysis detects recursive groups
and tables their bound calls. Programs describe relations without choosing the
engine's search strategy.


For the normative language definition, including lexical syntax, terms, clauses, goals, built-ins, automatic hybrid reasoning, `materialize/2`, and conformance boundaries, read the [Eyepl language reference](language-reference.md).

For the project's scope, design commitments, and position on ISO Prolog and
RDF interoperability, read [The Eyepl Position](position.md).

## Contents

1. [Quick start](#quick-start)
2. [Running the `eyepl` CLI](#running-the-eyepl-cli)
3. [RDF 1.2 interoperability](#rdf-12-interoperability)
4. [Default output](#default-output)
5. [Writing programs](#writing-programs)
6. [Aggregation helpers](#aggregation-helpers)
7. [Context data](#context-data)
8. [Example catalog](#example-catalog)
9. [Golden outputs, tests, and conformance](#golden-outputs-tests-and-conformance)
10. [Development and release](#development-and-release)
11. [Relationship to Eyeling](#relationship-to-eyeling)
12. [Performance notes](#performance-notes)
13. [Implementation limits](#implementation-limits)

## Quick start

Eyepl has no build step. From a source checkout, install dependencies and run
the CLI entry point directly with Node.js 18 or newer:

```sh
npm install
node bin/eyepl.js --version
node bin/eyepl.js examples/ancestor.pl
node bin/eyepl.js facts.pl rules.pl
printf 'works(stdin, true) :- eq(ok, ok).\n' | node bin/eyepl.js -
```

To install the published CLI instead, use:

```sh
npm install --global eyepl
eyepl --version
```

You can also use npm's local package-bin runner from the checkout:

```sh
npm exec --yes --package=. -- eyepl --version
npm exec --yes --package=. -- eyepl examples/ancestor.pl
```

To make the `eyepl` command available on your `PATH` while developing this checkout, prefer npm's package link instead of a manual symlink:

```sh
npm link
eyepl --version
```

`npm install -g .` is another local-checkout option if you want npm to install the package globally instead of linking it. Avoid hand-written `/usr/local/bin` symlinks unless you really need one; npm already reads the `bin` entry in `package.json` and creates the correct executable shim.

## Running the `eyepl` CLI

The commands in this section use `eyepl` for readability. In a source checkout where you have not run `npm link` or `npm install -g .`, replace `eyepl` with `node bin/eyepl.js`, or run the command through `npm exec --yes --package=. -- eyepl`.

Show the package version:

```sh
eyepl --version
eyepl -v
```

Run a program and let Eyepl print derived binary facts:

```sh
eyepl examples/ancestor.pl
```

Enable proof explanations when you want machine-readable provenance:

```sh
eyepl --proof examples/ancestor.pl
eyepl -p examples/ancestor.pl
```

Eyepl-readable explanations are opt-in proof output. Each `why/2` fact contains a nested abstract proof term, and a blank line separates consecutive explanations. Using Eyepl syntax for explanations keeps them in the same language as the answers themselves: they are readable by humans, parseable by Eyepl, easy to test, and can be transformed or explained further like any other Eyepl data. For example:

```eyepl
type(socrates, mortal).
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

The explanation output can itself be read as Eyepl input; for example, another program can materialize `why/2` facts such as `why(type(socrates, mortal), Proof)`. `--proof` adds only these explanation facts; it does not change the answers found by the solver.

### Explanation cookbook

Eyepl answers can carry their own provenance when proof output is enabled.

Explain one derived fact:

```sh
eyepl --proof examples/socrates.pl
```

The output contains the answer and a `why/2` fact. The proof term shows the source rule that produced the answer and the source fact used below it. Source references use `rule("file.pl", clause(N))` and `fact("file.pl", clause(N))`, where `N` is the 1-based clause number in that file.

Inspect variable bindings with a small policy program:

```eyepl
score(case1, 95).
threshold(90).

status(Case, accepted) :-
  score(Case, Score),
  threshold(T),
  ge(Score, T).
```

```sh
eyepl --proof policy.pl
```

The explanation contains the instantiated answer and the variables that made the rule succeed:

```eyepl
status(case1, accepted).
why(
  status(case1, accepted),
  proof(
    goal(status(case1, accepted)),
    by(rule("policy.pl", clause(3))),
    bindings([binding("Case", case1), binding("Score", 95), binding("T", 90)]),
    uses([...])
  )
).
```

Use the `uses([...])` list to follow the proof tree. In the policy example it contains one subproof for `score(case1, 95)`, one for `threshold(90)`, and one for the built-in comparison `ge(95, 90)`. Built-ins are shown as `builtin(Name, Arity)` because they do not come from source clauses.

Reuse explanations as data:

```sh
eyepl --proof examples/socrates.pl > socrates.why.pl
```

The resulting file is ordinary Eyepl syntax containing both answers and `why/2` proof facts.

Compose multiple files, stdin, and URLs:

```sh
eyepl facts.pl rules.pl
printf 'works(stdin, true) :- eq(ok, ok).\n' | eyepl -
eyepl https://example.test/program.pl
```

## RDF 1.2 interoperability

RDF support is an adapter around the ordinary Eyepl language; the parser and
solver remain RDF-agnostic. A typical round trip has three stages:

```sh
node tools/rdf-to-eyepl.mjs --rules rules.pl data.trig -o program.pl
eyepl program.pl > derived.pl
node tools/eyepl-to-rdf.mjs derived.pl -o derived.nq
```

`rdf-to-eyepl.mjs` detects the input syntax from its extension. It accepts RDF
1.2 Turtle (`.ttl`), TriG (`.trig`), N-Triples (`.nt`), N-Quads (`.nq`) and
RDF/XML (`.rdf`, `.rdfxml`, `.owl`). It also accepts JSON-LD, RDFa, Microdata,
Notation3 and SHACL Compact Syntax. Relative IRIs resolve against the input
file URL unless `--base IRI` overrides it.

When reading stdin there is no filename to inspect, so `--format` is required.
It accepts either an extension-style name or an RDF media type:

```sh
node tools/rdf-to-eyepl.mjs --format ttl --base https://example/ - -o program.pl
node tools/rdf-to-eyepl.mjs --format application/ld+json - -o program.pl
```

The generated program declares `materialize(rdf, 4)` and represents every quad
as `rdf(Subject, Predicate, Object, Graph)`. The lossless term mapping is:

| RDF value | Eyepl term |
| --- | --- |
| IRI | `iri(Value)` |
| blank node | `bnode(Scope, Label)` |
| typed literal | `literal(Value, datatype(IRI))` |
| language string | `literal(Value, lang(Language))` |
| directional language string | `literal(Value, lang(Language, ltr))` or `lang(Language, rtl)` |
| RDF 1.2 triple term | `triple(Subject, Predicate, Object)` |
| default graph | `default_graph` |

Triple terms may be nested. Named graphs use their IRI or blank-node term in
the fourth position. Blank-node scopes prevent labels from different input
documents from being conflated.

By default, source quads are inputs but are not copied to output: only quads
derived by a rule are emitted. Pass `--include-source` to retain both source
and derived quads. In that mode the generated program stores input as
`source_rdf/4` and adds a rule that copies it into `rdf/4`.

Rules use the same `rdf/4` representation. For example:

```eyepl
rdf(S, iri("https://example/ancestor"), O, G) :-
  rdf(S, iri("https://example/parent"), O, G).
```

Output is always RDF 1.2 N-Quads. See the compact
[RDF tools reference](../tools/README.md) for all command options.

## Default output

Eyepl programs write relation predicates directly:

```eyepl
parent(pat, jan).
parent(jan, emma).

ancestor(X, Y) :- parent(X, Y).
ancestor(X, Z) :- parent(X, Y), ancestor(Y, Z).
```

By default, Eyepl asks for new ground consequences of selected output predicates, suppresses duplicates, excludes source facts, sorts the result, and prints Prolog facts:

```eyepl
ancestor(jan, emma).
ancestor(pat, emma).
ancestor(pat, jan).
```

This default is intentionally output-oriented. It is not a complete bottom-up saturation engine. Built-ins and proof search remain goal-directed; use `materialize/2` declarations and small output predicates when you want a specific relation, arity, or non-binary answer.

### Focusing default output

Large examples often have internal helper predicates. Add `materialize/2` declarations to restrict default output to selected predicates:

```eyepl
materialize(answer, 2).

seed(case1).
helper(Case, score(95)) :- seed(Case).
answer(Case, accepted) :- helper(Case, score(95)).
```

The default output is then:

```eyepl
answer(case1, accepted).
```

`materialize/2` is a declaration, not a logical rule to prove. It affects which predicates the CLI prints, not the meaning of the rules themselves. Materialized output facts are not inserted back into the running program for later goals. Source facts are indexed and reused normally, and answers for automatically tabled recursive predicates are reused inside the same solver run.

## Writing programs

A good Eyepl program normally has three layers:

1. source facts;
2. helper predicates for calculation or search;
3. concise relation-style outputs, usually binary predicates such as `status(Case, Value)`, `reason(Case, Text)`, `ancestor(Person, Ancestor)`, or `cost(Path, Amount)`.

Example:

```eyepl
score(case1, 95).
threshold(90).

accepted(Case) :-
  score(Case, Score),
  threshold(Threshold),
  ge(Score, Threshold).

status(Case, accepted) :- accepted(Case).
reason(Case, "score exceeds threshold") :- accepted(Case).
```

When `status/2` and `reason/2` are derived, they appear in default output. If the program has many helper binary predicates, declare the intended output predicates:

```eyepl
materialize(status, 2).
materialize(reason, 2).
```

### Naming

Predicate names and atom constants use the same lexical form. Namespace-like names should be plain names such as `type`, `person_name`, or `odrl_permission`; colon names are not part of the language.

### Embedding remains general

The CLI is output-oriented and uses `materialize/2` to decide what to print. Embedders can still use the JavaScript API and `Solver` directly for arbitrary goals and arities.

Add `-s` or `--stats` when you want lightweight solver counters on stderr without changing stdout:

```sh
eyepl -s examples/observability-log-correlation.pl
```

Add `-w` or `--warnings` when you want non-fatal portability diagnostics, such as unstratified `not/1` dependencies, printed to stderr while normal answer output still goes to stdout:

```sh
eyepl --warnings test/conformance/warnings/negation/unstratified_mutual.pl
```

The playground has matching `--stats` and `--proof` checkboxes, so browser runs can show the same counters or explanations like the CLI.


### Builtins

Eyepl builtins are registered by name and arity in small modules under [`src/builtins`](../src/builtins). This keeps the runtime portable to Node.js and the browser while giving each builtin family a clear boundary. Built-ins are called as ordinary Eyepl predicates. See the [Eyepl language reference](language-reference.md#9-standard-built-in-predicates) for the portable profile. The bundled implementation currently registers 80 name/arity entries across 78 predicate names:

| Family | Count | Built-ins |
|---|---:|---|
| Core and host | 4 | `eq/2`, `neq/2`, `local_time/1`, `difference/3` |
| Arithmetic, comparison, and generators | 29 | `neg/2`, `abs/2`, `sin/2`, `cos/2`, `tan/2`, `asin/2`, `acos/2`, `sqrt/2`, `floor/2`, `ceiling/2`, `trunc/2`, `rounded/2`, `exp/2`, `log/2`, `add/3`, `sub/3`, `mul/3`, `div/3`, `mod/3`, `min/3`, `max/3`, `pow/3`, `atan2/3`, `lt/2`, `gt/2`, `le/2`, `ge/2`, `between/3`, `smallest_divisor_from/3` |
| Strings and conversions | 15 | `str_concat/3`, `contains/2`, `matches/2`, `matches/3`, `not_matches/2`, `split/3`, `join/3`, `substring/4`, `replace/4`, `lowercase/2`, `uppercase/2`, `trim/2`, `number_string/2`, `atom_string/2`, `term_string/2` |
| Lists | 19 | `append/3`, `nth0/3`, `set_nth0/4`, `head/2`, `rest/2`, `last/2`, `take/3`, `drop/3`, `slice/4`, `member/2`, `select/3`, `not_member/2`, `reverse/2`, `length/2`, `sum_list/2`, `min_list/2`, `max_list/2`, `list_to_set/2`, `sort/2` |
| Aggregation | 5 | `findall/3`, `countall/2`, `sumall/3`, `aggregate_min/5`, `aggregate_max/5` |
| Control | 3 | `not/1`, `once/1`, `forall/2` |
| Context and terms | 5 | `holds/2`, `holds/3`, `functor/3`, `arg/3`, `compound_name_arguments/3` |
| **Total** | **80** |  |


To add a builtin, create or extend a module with `register(registry)` and call `registry.add(name, arity, handler, options)`. The default registry is assembled in [`src/builtins/registry.js`](../src/builtins/registry.js). Builtins that are only safe for specific argument modes should provide a `ready` predicate and `fallbackWhenNotReady: true`, so user-defined clauses remain visible until the builtin is applicable.


## Aggregation helpers

Eyepl includes goal-directed aggregation helpers for finite searches:

```eyepl
countall(Goal, Count).
sumall(Value, Goal, Sum).
aggregate_min(Key, Template, Goal, Bestkey, Besttemplate).
aggregate_max(Key, Template, Goal, Bestkey, Besttemplate).
```

Use `countall/2` for solution counts, `sumall/3` for numeric totals, and `aggregate_min/5` or `aggregate_max/5` when a search should keep only the best candidate instead of collecting and sorting every answer. The key can be a number, atom constant, string, compound term, or list; normal term ordering is used, so compound keys such as `[Cost, Path]` are useful for deterministic tie-breaking.

Example:

```eyepl
best_cycle(Cycle, Cost) :-
  cities(Cities),
  aggregate_min([Cost, Cycle], Cycle, candidate_cycle(Cities, Cycle, Cost), [Cost, Cycle], Cycle).
```

## Context data

Comma terms can be data as well as conjunctions. Eyepl provides two context utilities:

```eyepl
holds((name(alice, "Alice"), knows(alice, bob)), name(S, O)).
holds((ready, name(alice, "Alice"), route(alice, bob, 7)), Name, Args).
```

Use `holds/2` when you want to match the member term directly, for example `name(S, O)`, `route(A, B, Cost)`, or `edge(A, arc(B, Cost))`. Use `holds/3` when you need the predicate name and argument list as data: it exposes any-arity member as atom constant `Name` plus a proper list `Args`, so zero-, binary-, and ternary members appear as `ready/0`, `name/2`, and `route/3` shapes without a special binary predicate. These utilities are useful for quoted context data, but they do not make those context members true in the ambient program. The [`context-schema-audit.pl`](../examples/context-schema-audit.pl) example shows a case that really needs `holds/3`: it audits heterogeneous message contexts by extracting every member as `Name + Args`, computing each arity, and checking the resulting shape against a schema without knowing the predicate names in advance.

`matches/3` can create context data from named regular-expression captures, which is useful when text logs or messages need to become facts before later rules inspect them with `holds/2` or `holds/3`. See [`observability-log-correlation.pl`](../examples/observability-log-correlation.pl) for a complete log-correlation example.


## Example catalog

| Example | Description | Golden output |
| --- | --- | --- |
| [`abstract-interpretation.pl`](../examples/abstract-interpretation.pl) | Performs a sign-domain abstract interpretation and reports a possible divide-by-zero warning. | [`output/abstract-interpretation.pl`](../examples/output/abstract-interpretation.pl) |
| [`access-control-policy.pl`](../examples/access-control-policy.pl) | Evaluates role and condition based access decisions. | [`output/access-control-policy.pl`](../examples/output/access-control-policy.pl) |
| [`ackermann.pl`](../examples/ackermann.pl) | Computes Ackermann-style hyperoperation values. | [`output/ackermann.pl`](../examples/output/ackermann.pl) |
| [`age.pl`](../examples/age.pl) | Checks whether people meet age thresholds. | [`output/age.pl`](../examples/output/age.pl) |
| [`aliases-and-namespaces.pl`](../examples/aliases-and-namespaces.pl) | Shows ordinary predicate names for vocabulary aliases. | [`output/aliases-and-namespaces.pl`](../examples/output/aliases-and-namespaces.pl) |
| [`alignment-demo.pl`](../examples/alignment-demo.pl) | Rolls dataset concepts up through a small alignment taxonomy. | [`output/alignment-demo.pl`](../examples/output/alignment-demo.pl) |
| [`allen-interval-calculus.pl`](../examples/allen-interval-calculus.pl) | Classifies interval relations with integer time offsets. | [`output/allen-interval-calculus.pl`](../examples/output/allen-interval-calculus.pl) |
| [`ancestor.pl`](../examples/ancestor.pl) | Derives ancestors from parent facts. | [`output/ancestor.pl`](../examples/output/ancestor.pl) |
| [`animal.pl`](../examples/animal.pl) | Classifies animals from traits. | [`output/animal.pl`](../examples/output/animal.pl) |
| [`annotation.pl`](../examples/annotation.pl) | Derives facts from quoted annotation data. | [`output/annotation.pl`](../examples/output/annotation.pl) |
| [`auroracare.pl`](../examples/auroracare.pl) | Evaluates purpose-based medical data access scenarios. | [`output/auroracare.pl`](../examples/output/auroracare.pl) |
| [`backward.pl`](../examples/backward.pl) | Shows a backward-rule pattern as a goal-directed numeric rule. | [`output/backward.pl`](../examples/output/backward.pl) |
| [`basic-monadic.pl`](../examples/basic-monadic.pl) | Runs the basic monadic benchmark with explicit indexed edge joins instead of specialized search builtins. | [`output/basic-monadic.pl`](../examples/output/basic-monadic.pl) |
| [`bayes-diagnosis.pl`](../examples/bayes-diagnosis.pl) | Computes scaled Bayesian diagnosis posteriors. | [`output/bayes-diagnosis.pl`](../examples/output/bayes-diagnosis.pl) |
| [`bayes-therapy.pl`](../examples/bayes-therapy.pl) | Ranks therapies using Bayesian disease likelihoods. | [`output/bayes-therapy.pl`](../examples/output/bayes-therapy.pl) |
| [`beam-deflection.pl`](../examples/beam-deflection.pl) | Computes cantilever beam deflection. | [`output/beam-deflection.pl`](../examples/output/beam-deflection.pl) |
| [`binomial-vandermonde.pl`](../examples/binomial-vandermonde.pl) | Computes binomial coefficients and checks Vandermonde's identity. | [`output/binomial-vandermonde.pl`](../examples/output/binomial-vandermonde.pl) |
| [`blocks-world-planning.pl`](../examples/blocks-world-planning.pl) | Searches a finite blocks-world plan. | [`output/blocks-world-planning.pl`](../examples/output/blocks-world-planning.pl) |
| [`bmi.pl`](../examples/bmi.pl) | Normalizes BMI inputs and classifies weight. | [`output/bmi.pl`](../examples/output/bmi.pl) |
| [`braking-safety-worlds.pl`](../examples/braking-safety-worlds.pl) | Classifies braking safety under alternative worlds. | [`output/braking-safety-worlds.pl`](../examples/output/braking-safety-worlds.pl) |
| [`buck-converter-design.pl`](../examples/buck-converter-design.pl) | Checks buck-converter ripple design. | [`output/buck-converter-design.pl`](../examples/output/buck-converter-design.pl) |
| [`cache-performance.pl`](../examples/cache-performance.pl) | Summarizes cache latency performance. | [`output/cache-performance.pl`](../examples/output/cache-performance.pl) |
| [`canary-release.pl`](../examples/canary-release.pl) | Decides canary rollout or rollback. | [`output/canary-release.pl`](../examples/output/canary-release.pl) |
| [`cat-koko.pl`](../examples/cat-koko.pl) | Demonstrates named existential witnesses from a Cat Koko rule pattern. | [`output/cat-koko.pl`](../examples/output/cat-koko.pl) |
| [`catalan-convolution.pl`](../examples/catalan-convolution.pl) | Computes Catalan numbers by automatically tabled convolution. | [`output/catalan-convolution.pl`](../examples/output/catalan-convolution.pl) |
| [`cdcl-sat-solver.pl`](../examples/cdcl-sat-solver.pl) | Simulates one CDCL conflict-analysis step with a learned clause and backjumped model. | [`output/cdcl-sat-solver.pl`](../examples/output/cdcl-sat-solver.pl) |
| [`chart-parser.pl`](../examples/chart-parser.pl) | Parses small sentences with an automatically tabled chart parser. | [`output/chart-parser.pl`](../examples/output/chart-parser.pl) |
| [`clinical-trial-screening.pl`](../examples/clinical-trial-screening.pl) | Screens candidates for a trial. | [`output/clinical-trial-screening.pl`](../examples/output/clinical-trial-screening.pl) |
| [`collatz-1000.pl`](../examples/collatz-1000.pl) | Materializes Collatz trajectories for starts 1000 down to 1. | [`output/collatz-1000.pl`](../examples/output/collatz-1000.pl) |
| [`combinatorics-findall-sort.pl`](../examples/combinatorics-findall-sort.pl) | Collects and sorts finite combinations. | [`output/combinatorics-findall-sort.pl`](../examples/output/combinatorics-findall-sort.pl) |
| [`competitive-enzyme-kinetics.pl`](../examples/competitive-enzyme-kinetics.pl) | Computes inhibited enzyme reaction rates. | [`output/competitive-enzyme-kinetics.pl`](../examples/output/competitive-enzyme-kinetics.pl) |
| [`complex.pl`](../examples/complex.pl) | Performs arithmetic on complex pairs. | [`output/complex.pl`](../examples/output/complex.pl) |
| [`composition-of-injective-functions-is-injective.pl`](../examples/composition-of-injective-functions-is-injective.pl) | Encodes composition and injectivity of finite functions. | [`output/composition-of-injective-functions-is-injective.pl`](../examples/output/composition-of-injective-functions-is-injective.pl) |
| [`context-association.pl`](../examples/context-association.pl) | Associates named contexts with their contents. | [`output/context-association.pl`](../examples/output/context-association.pl) |
| [`context-schema-audit.pl`](../examples/context-schema-audit.pl) | Audits mixed-arity context members with `holds/3`. | [`output/context-schema-audit.pl`](../examples/output/context-schema-audit.pl) |
| [`continued-fraction-sqrt2.pl`](../examples/continued-fraction-sqrt2.pl) | Computes sqrt(2) continued-fraction convergents and Pell errors. | [`output/continued-fraction-sqrt2.pl`](../examples/output/continued-fraction-sqrt2.pl) |
| [`control-system.pl`](../examples/control-system.pl) | Evaluates control-system measurements and targets. | [`output/control-system.pl`](../examples/output/control-system.pl) |
| [`critical-path-schedule.pl`](../examples/critical-path-schedule.pl) | Computes earliest starts and the critical path for a project network. | [`output/critical-path-schedule.pl`](../examples/output/critical-path-schedule.pl) |
| [`cyclic-path.pl`](../examples/cyclic-path.pl) | Computes paths in a cyclic graph. | [`output/cyclic-path.pl`](../examples/output/cyclic-path.pl) |
| [`d3-group.pl`](../examples/d3-group.pl) | Enumerates subgroups of the D3 group. | [`output/d3-group.pl`](../examples/output/d3-group.pl) |
| [`dairy-energy-balance.pl`](../examples/dairy-energy-balance.pl) | Classifies dairy cow energy balance. | [`output/dairy-energy-balance.pl`](../examples/output/dairy-energy-balance.pl) |
| [`data-negotiation.pl`](../examples/data-negotiation.pl) | Chooses an accepted data-negotiation offer. | [`output/data-negotiation.pl`](../examples/output/data-negotiation.pl) |
| [`relational-cube-lookup.pl`](../examples/relational-cube-lookup.pl) | Benchmarks 2,000 multi-key lookups over a relational cube containing 3,375 facts. | [`output/relational-cube-lookup.pl`](../examples/output/relational-cube-lookup.pl) |
| [`deep-taxonomy-10.pl`](../examples/deep-taxonomy-10.pl) | Stress-tests recursive taxonomy depth 10. | [`output/deep-taxonomy-10.pl`](../examples/output/deep-taxonomy-10.pl) |
| [`deep-taxonomy-100.pl`](../examples/deep-taxonomy-100.pl) | Stress-tests recursive taxonomy depth 100. | [`output/deep-taxonomy-100.pl`](../examples/output/deep-taxonomy-100.pl) |
| [`deep-taxonomy-1000.pl`](../examples/deep-taxonomy-1000.pl) | Stress-tests recursive taxonomy depth 1000. | [`output/deep-taxonomy-1000.pl`](../examples/output/deep-taxonomy-1000.pl) |
| [`deep-taxonomy-10000.pl`](../examples/deep-taxonomy-10000.pl) | Stress-tests recursive taxonomy depth 10000. | [`output/deep-taxonomy-10000.pl`](../examples/output/deep-taxonomy-10000.pl) |
| [`deep-taxonomy-100000.pl`](../examples/deep-taxonomy-100000.pl) | Stress-tests recursive taxonomy depth 100000. | [`output/deep-taxonomy-100000.pl`](../examples/output/deep-taxonomy-100000.pl) |
| [`delfour.pl`](../examples/delfour.pl) | Derives shopping and authorization recommendations. | [`output/delfour.pl`](../examples/output/delfour.pl) |
| [`deontic-logic.pl`](../examples/deontic-logic.pl) | Reports obligations, prohibitions, and violations. | [`output/deontic-logic.pl`](../examples/output/deontic-logic.pl) |
| [`derived-backward-rule.pl`](../examples/derived-backward-rule.pl) | Derives an inverse-property backward rule from rule data. | [`output/derived-backward-rule.pl`](../examples/output/derived-backward-rule.pl) |
| [`derived-rule.pl`](../examples/derived-rule.pl) | Derives conclusions from rule data. | [`output/derived-rule.pl`](../examples/output/derived-rule.pl) |
| [`diamond-property.pl`](../examples/diamond-property.pl) | Checks the diamond property of a relation. | [`output/diamond-property.pl`](../examples/output/diamond-property.pl) |
| [`dijkstra-findall-sort.pl`](../examples/dijkstra-findall-sort.pl) | Finds shortest paths using collected candidates. | [`output/dijkstra-findall-sort.pl`](../examples/output/dijkstra-findall-sort.pl) |
| [`dijkstra-risk-path.pl`](../examples/dijkstra-risk-path.pl) | Ranks routes by cost and trust. | [`output/dijkstra-risk-path.pl`](../examples/output/dijkstra-risk-path.pl) |
| [`dijkstra.pl`](../examples/dijkstra.pl) | Enumerates weighted simple paths. | [`output/dijkstra.pl`](../examples/output/dijkstra.pl) |
| [`dining-philosophers.pl`](../examples/dining-philosophers.pl) | Simulates Chandy-Misra fork exchanges. | [`output/dining-philosophers.pl`](../examples/output/dining-philosophers.pl) |
| [`dog.pl`](../examples/dog.pl) | Counts dogs and derives when a license is required. | [`output/dog.pl`](../examples/output/dog.pl) |
| [`dpv-odrl-purpose-mapping.pl`](../examples/dpv-odrl-purpose-mapping.pl) | Maps a DPV process into an ODRL permission view. | [`output/dpv-odrl-purpose-mapping.pl`](../examples/output/dpv-odrl-purpose-mapping.pl) |
| [`drone-corridor-planner.pl`](../examples/drone-corridor-planner.pl) | Plans bounded drone corridor routes. | [`output/drone-corridor-planner.pl`](../examples/output/drone-corridor-planner.pl) |
| [`easter-computus.pl`](../examples/easter-computus.pl) | Computes Gregorian Easter dates. | [`output/easter-computus.pl`](../examples/output/easter-computus.pl) |
| [`electrical-rc-filter.pl`](../examples/electrical-rc-filter.pl) | Sizes an RC low-pass filter. | [`output/electrical-rc-filter.pl`](../examples/output/electrical-rc-filter.pl) |
| [`equality-saturation.pl`](../examples/equality-saturation.pl) | Performs bounded equality saturation and extracts the cheapest equivalent expression. | [`output/equality-saturation.pl`](../examples/output/equality-saturation.pl) |
| [`epidemic-policy.pl`](../examples/epidemic-policy.pl) | Chooses policies from risk and social cost. | [`output/epidemic-policy.pl`](../examples/output/epidemic-policy.pl) |
| [`equivalence-classes-overlap-implies-same-class.pl`](../examples/equivalence-classes-overlap-implies-same-class.pl) | Packages the shared-member proof pattern for equivalence classes. | [`output/equivalence-classes-overlap-implies-same-class.pl`](../examples/output/equivalence-classes-overlap-implies-same-class.pl) |
| [`eulerian-path.pl`](../examples/eulerian-path.pl) | Finds an Eulerian path using each edge once. | [`output/eulerian-path.pl`](../examples/output/eulerian-path.pl) |
| [`ev-range-worlds.pl`](../examples/ev-range-worlds.pl) | Estimates electric-vehicle trip feasibility. | [`output/ev-range-worlds.pl`](../examples/output/ev-range-worlds.pl) |
| [`existential-rule.pl`](../examples/existential-rule.pl) | Represents existential-style witnesses with explicit Herbrand terms. | [`output/existential-rule.pl`](../examples/output/existential-rule.pl) |
| [`exoplanet-validation-worlds.pl`](../examples/exoplanet-validation-worlds.pl) | Validates exoplanet candidates across worlds. | [`output/exoplanet-validation-worlds.pl`](../examples/output/exoplanet-validation-worlds.pl) |
| [`expression-eval.pl`](../examples/expression-eval.pl) | Evaluates a small arithmetic expression tree. | [`output/expression-eval.pl`](../examples/output/expression-eval.pl) |
| [`family-cousins.pl`](../examples/family-cousins.pl) | Derives cousin and family labels. | [`output/family-cousins.pl`](../examples/output/family-cousins.pl) |
| [`fastpow.pl`](../examples/fastpow.pl) | Computes powers by repeated squaring. | [`output/fastpow.pl`](../examples/output/fastpow.pl) |
| [`fft8-numeric.pl`](../examples/fft8-numeric.pl) | Runs an 8-point FFT over complex pairs. | [`output/fft8-numeric.pl`](../examples/output/fft8-numeric.pl) |
| [`fibonacci.pl`](../examples/fibonacci.pl) | Computes large Fibonacci numbers by fast doubling. | [`output/fibonacci.pl`](../examples/output/fibonacci.pl) |
| [`field-nitrogen-balance.pl`](../examples/field-nitrogen-balance.pl) | Classifies field nitrogen balance. | [`output/field-nitrogen-balance.pl`](../examples/output/field-nitrogen-balance.pl) |
| [`flandor.pl`](../examples/flandor.pl) | Derives a Flanders macro-insight authorization and retooling package. | [`output/flandor.pl`](../examples/output/flandor.pl) |
| [`floating-point.pl`](../examples/floating-point.pl) | Exercises floating-point arithmetic and comparisons. | [`output/floating-point.pl`](../examples/output/floating-point.pl) |
| [`four-color-map.pl`](../examples/four-color-map.pl) | Checks a four-colour map assignment. | [`output/four-color-map.pl`](../examples/output/four-color-map.pl) |
| [`fundamental-theorem-arithmetic.pl`](../examples/fundamental-theorem-arithmetic.pl) | Factors integers and reconstructs products. | [`output/fundamental-theorem-arithmetic.pl`](../examples/output/fundamental-theorem-arithmetic.pl) |
| [`gd-step-certified.pl`](../examples/gd-step-certified.pl) | Certifies a gradient-descent step. | [`output/gd-step-certified.pl`](../examples/output/gd-step-certified.pl) |
| [`gdpr-compliance.pl`](../examples/gdpr-compliance.pl) | Checks GDPR-style processing compliance. | [`output/gdpr-compliance.pl`](../examples/output/gdpr-compliance.pl) |
| [`good-cobbler.pl`](../examples/good-cobbler.pl) | Demonstrates term-level structure with a good-cobbler statement. | [`output/good-cobbler.pl`](../examples/output/good-cobbler.pl) |
| [`gps.pl`](../examples/gps.pl) | Finds and verifies route paths. | [`output/gps.pl`](../examples/output/gps.pl) |
| [`graph-reachability.pl`](../examples/graph-reachability.pl) | Derives reachable nodes in a graph. | [`output/graph-reachability.pl`](../examples/output/graph-reachability.pl) |
| [`graph.pl`](../examples/graph.pl) | Derives transitive paths over French-city road links while showing the productive recursive rule order. | [`output/graph.pl`](../examples/output/graph.pl) |
| [`gray-code-counter.pl`](../examples/gray-code-counter.pl) | Generates Gray-code counter states. | [`output/gray-code-counter.pl`](../examples/output/gray-code-counter.pl) |
| [`greatest-lower-bound-uniqueness.pl`](../examples/greatest-lower-bound-uniqueness.pl) | Shows uniqueness of greatest lower bounds in a finite order instance. | [`output/greatest-lower-bound-uniqueness.pl`](../examples/output/greatest-lower-bound-uniqueness.pl) |
| [`group-inverse-uniqueness.pl`](../examples/group-inverse-uniqueness.pl) | Shows uniqueness of inverses in a finite group instance. | [`output/group-inverse-uniqueness.pl`](../examples/output/group-inverse-uniqueness.pl) |
| [`hamiltonian-path.pl`](../examples/hamiltonian-path.pl) | Finds a Hamiltonian path. | [`output/hamiltonian-path.pl`](../examples/output/hamiltonian-path.pl) |
| [`hamming-code.pl`](../examples/hamming-code.pl) | Corrects a single-bit Hamming word. | [`output/hamming-code.pl`](../examples/output/hamming-code.pl) |
| [`hanoi.pl`](../examples/hanoi.pl) | Derives the Towers of Hanoi moves. | [`output/hanoi.pl`](../examples/output/hanoi.pl) |
| [`heat-loss.pl`](../examples/heat-loss.pl) | Computes conductive heat loss. | [`output/heat-loss.pl`](../examples/output/heat-loss.pl) |
| [`herbrand-semantics.pl`](../examples/herbrand-semantics.pl) | Shows how unique names and free constructors make symbolic identity predictable. | [`output/herbrand-semantics.pl`](../examples/output/herbrand-semantics.pl) |
| [`herbrand-witnesses.pl`](../examples/herbrand-witnesses.pl) | Represents existential-style consequences as stable Herbrand witness terms. | [`output/herbrand-witnesses.pl`](../examples/output/herbrand-witnesses.pl) |
| [`heron-theorem.pl`](../examples/heron-theorem.pl) | Computes triangle area by Heron's theorem. | [`output/heron-theorem.pl`](../examples/output/heron-theorem.pl) |
| [`ideal-gas-law.pl`](../examples/ideal-gas-law.pl) | Applies the ideal gas law. | [`output/ideal-gas-law.pl`](../examples/output/ideal-gas-law.pl) |
| [`illegitimate-reasoning.pl`](../examples/illegitimate-reasoning.pl) | Detects suspect reasoning patterns. | [`output/illegitimate-reasoning.pl`](../examples/output/illegitimate-reasoning.pl) |
| [`integer-partitions.pl`](../examples/integer-partitions.pl) | Counts integer partitions with automatic tabling. | [`output/integer-partitions.pl`](../examples/output/integer-partitions.pl) |
| [`intuitionistic-logic-kripke.pl`](../examples/intuitionistic-logic-kripke.pl) | Emulates intuitionistic Kripke forcing and constructive implication. | [`output/intuitionistic-logic-kripke.pl`](../examples/output/intuitionistic-logic-kripke.pl) |
| [`job-shop-scheduling.pl`](../examples/job-shop-scheduling.pl) | Searches a small job-shop schedule and minimizes makespan. | [`output/job-shop-scheduling.pl`](../examples/output/job-shop-scheduling.pl) |
| [`knapsack-optimization.pl`](../examples/knapsack-optimization.pl) | Optimizes a finite 0/1 knapsack pack with aggregation. | [`output/knapsack-optimization.pl`](../examples/output/knapsack-optimization.pl) |
| [`knuth-bendix-completion.pl`](../examples/knuth-bendix-completion.pl) | Checks bounded Knuth-Bendix-style critical pairs for joinability. | [`output/knuth-bendix-completion.pl`](../examples/output/knuth-bendix-completion.pl) |
| [`knowledge-engineering-alignment-flow.pl`](../examples/knowledge-engineering-alignment-flow.pl) | Specializes reusable alignment rules into a target-shaped flow view. | [`output/knowledge-engineering-alignment-flow.pl`](../examples/output/knowledge-engineering-alignment-flow.pl) |
| [`language.pl`](../examples/language.pl) | Shows the modern Eyepl surface syntax in one compact recursive graph example. | [`output/language.pl`](../examples/output/language.pl) |
| [`law-of-cosines.pl`](../examples/law-of-cosines.pl) | Computes a triangle side by cosine law. | [`output/law-of-cosines.pl`](../examples/output/law-of-cosines.pl) |
| [`least-squares-regression.pl`](../examples/least-squares-regression.pl) | Fits a least-squares regression line. | [`output/least-squares-regression.pl`](../examples/output/least-squares-regression.pl) |
| [`linear-logic-resources.pl`](../examples/linear-logic-resources.pl) | Emulates linear logic resource consumption with explicit state threading. | [`output/linear-logic-resources.pl`](../examples/output/linear-logic-resources.pl) |
| [`list-collection.pl`](../examples/list-collection.pl) | Demonstrates list and collection built-ins. | [`output/list-collection.pl`](../examples/output/list-collection.pl) |
| [`lldm.pl`](../examples/lldm.pl) | Calculates leg-length discrepancy measurements. | [`output/lldm.pl`](../examples/output/lldm.pl) |
| [`manufacturing-quality-control.pl`](../examples/manufacturing-quality-control.pl) | Evaluates process capability and quality. | [`output/manufacturing-quality-control.pl`](../examples/output/manufacturing-quality-control.pl) |
| [`markov-logic-network.pl`](../examples/markov-logic-network.pl) | Scores finite possible worlds with weighted soft formulas in a Markov Logic Network style. | [`output/markov-logic-network.pl`](../examples/output/markov-logic-network.pl) |
| [`map-four-color-search.pl`](../examples/map-four-color-search.pl) | Searches for a valid four-colouring of the EU neighbour graph. | [`output/map-four-color-search.pl`](../examples/output/map-four-color-search.pl) |
| [`matrix-chain-order.pl`](../examples/matrix-chain-order.pl) | Finds an optimal matrix-chain multiplication order. | [`output/matrix-chain-order.pl`](../examples/output/matrix-chain-order.pl) |
| [`matrix-noncommutativity.pl`](../examples/matrix-noncommutativity.pl) | Multiplies 2x2 matrices and shows non-commutativity. | [`output/matrix-noncommutativity.pl`](../examples/output/matrix-noncommutativity.pl) |
| [`microgrid-dispatch.pl`](../examples/microgrid-dispatch.pl) | Plans microgrid dispatch and reserve. | [`output/microgrid-dispatch.pl`](../examples/output/microgrid-dispatch.pl) |
| [`missionaries-cannibals.pl`](../examples/missionaries-cannibals.pl) | Solves the missionaries-and-cannibals river crossing puzzle. | [`output/missionaries-cannibals.pl`](../examples/output/missionaries-cannibals.pl) |
| [`modal-logic-kripke.pl`](../examples/modal-logic-kripke.pl) | Emulates modal box and diamond operators over a finite Kripke frame. | [`output/modal-logic-kripke.pl`](../examples/output/modal-logic-kripke.pl) |
| [`modular-exponentiation.pl`](../examples/modular-exponentiation.pl) | Computes modular powers by repeated squaring. | [`output/modular-exponentiation.pl`](../examples/output/modular-exponentiation.pl) |
| [`monkey-bananas.pl`](../examples/monkey-bananas.pl) | Solves the monkey-and-bananas puzzle. | [`output/monkey-bananas.pl`](../examples/output/monkey-bananas.pl) |
| [`n-queens-8.pl`](../examples/n-queens-8.pl) | Solves the 8-queens search problem with diagonal constraints. | [`output/n-queens-8.pl`](../examples/output/n-queens-8.pl) |
| [`network-sla.pl`](../examples/network-sla.pl) | Checks network path SLA compliance. | [`output/network-sla.pl`](../examples/output/network-sla.pl) |
| [`newton-raphson.pl`](../examples/newton-raphson.pl) | Finds roots by Newton-Raphson iteration. | [`output/newton-raphson.pl`](../examples/output/newton-raphson.pl) |
| [`nixon-diamond.pl`](../examples/nixon-diamond.pl) | Reports the classic Nixon-diamond conflict. | [`output/nixon-diamond.pl`](../examples/output/nixon-diamond.pl) |
| [`observability-log-correlation.pl`](../examples/observability-log-correlation.pl) | Extracts named regex captures from observability logs and correlates events by trace id. | [`output/observability-log-correlation.pl`](../examples/output/observability-log-correlation.pl) |
| [`odrl-dpv-fpv-trust-flow.pl`](../examples/odrl-dpv-fpv-trust-flow.pl) | Decides ODRL/DPV data flows with local FPV trust gates. | [`output/odrl-dpv-fpv-trust-flow.pl`](../examples/output/odrl-dpv-fpv-trust-flow.pl) |
| [`odrl-dpv-healthcare-risk-ranked.pl`](../examples/odrl-dpv-healthcare-risk-ranked.pl) | Ranks healthcare policy risks and mitigations. | [`output/odrl-dpv-healthcare-risk-ranked.pl`](../examples/output/odrl-dpv-healthcare-risk-ranked.pl) |
| [`odrl-dpv-risk-ranked.pl`](../examples/odrl-dpv-risk-ranked.pl) | Ranks data-policy risks and mitigations. | [`output/odrl-dpv-risk-ranked.pl`](../examples/output/odrl-dpv-risk-ranked.pl) |
| [`orbital-transfer-design.pl`](../examples/orbital-transfer-design.pl) | Designs a Hohmann orbital transfer. | [`output/orbital-transfer-design.pl`](../examples/output/orbital-transfer-design.pl) |
| [`path-discovery.pl`](../examples/path-discovery.pl) | Discovers bounded air-route paths. | [`output/path-discovery.pl`](../examples/output/path-discovery.pl) |
| [`partial-evaluator.pl`](../examples/partial-evaluator.pl) | Specializes tiny expression programs by folding static inputs into residual code. | [`output/partial-evaluator.pl`](../examples/output/partial-evaluator.pl) |
| [`peano-arithmetic.pl`](../examples/peano-arithmetic.pl) | Computes Peano addition, multiplication, and factorial. | [`output/peano-arithmetic.pl`](../examples/output/peano-arithmetic.pl) |
| [`peano-calculus.pl`](../examples/peano-calculus.pl) | Computes Peano addition, multiplication, and factorial. | [`output/peano-calculus.pl`](../examples/output/peano-calculus.pl) |
| [`peasant.pl`](../examples/peasant.pl) | Performs peasant multiplication and exponentiation. | [`output/peasant.pl`](../examples/output/peasant.pl) |
| [`pell-equation.pl`](../examples/pell-equation.pl) | Generates Pell-equation solutions by recurrence. | [`output/pell-equation.pl`](../examples/output/pell-equation.pl) |
| [`pendulum-period.pl`](../examples/pendulum-period.pl) | Computes simple pendulum periods. | [`output/pendulum-period.pl`](../examples/output/pendulum-period.pl) |
| [`pointer-analysis.pl`](../examples/pointer-analysis.pl) | Computes Andersen-style inclusion-based points-to facts over address, assign, store, and load constraints. | [`output/pointer-analysis.pl`](../examples/output/pointer-analysis.pl) |
| [`polynomial.pl`](../examples/polynomial.pl) | Finds complex integer polynomial roots. | [`output/polynomial.pl`](../examples/output/polynomial.pl) |
| [`prime-range.pl`](../examples/prime-range.pl) | Finds primes in a finite range and computes a totient value. | [`output/prime-range.pl`](../examples/output/prime-range.pl) |
| [`proof-contrapositive.pl`](../examples/proof-contrapositive.pl) | Models proof by contrapositive. | [`output/proof-contrapositive.pl`](../examples/output/proof-contrapositive.pl) |
| [`quadratic-formula.pl`](../examples/quadratic-formula.pl) | Solves sample quadratic equations. | [`output/quadratic-formula.pl`](../examples/output/quadratic-formula.pl) |
| [`radioactive-decay.pl`](../examples/radioactive-decay.pl) | Computes radioactive decay over time. | [`output/radioactive-decay.pl`](../examples/output/radioactive-decay.pl) |
| [`rdf12-directional-language.pl`](../examples/rdf12-directional-language.pl) | Preserves RDF 1.2 language direction while deriving display labels. | [`output/rdf12-directional-language.pl`](../examples/output/rdf12-directional-language.pl) |
| [`rdf12-nested-triple-term.pl`](../examples/rdf12-nested-triple-term.pl) | Matches nested RDF 1.2 triple terms and derives their innermost relationship. | [`output/rdf12-nested-triple-term.pl`](../examples/output/rdf12-nested-triple-term.pl) |
| [`rdf12-trig-graph-join.pl`](../examples/rdf12-trig-graph-join.pl) | Joins TriG default-graph metadata with facts from a named graph. | [`output/rdf12-trig-graph-join.pl`](../examples/output/rdf12-trig-graph-join.pl) |
| [`rdf12-trig-named-graph.pl`](../examples/rdf12-trig-named-graph.pl) | Derives ancestor relationships within a TriG named graph. | [`output/rdf12-trig-named-graph.pl`](../examples/output/rdf12-trig-named-graph.pl) |
| [`rdf12-trig-triple-term.pl`](../examples/rdf12-trig-triple-term.pl) | Projects an RDF 1.2 triple term while preserving its TriG named graph. | [`output/rdf12-trig-triple-term.pl`](../examples/output/rdf12-trig-triple-term.pl) |
| [`rdf12-triple-term.pl`](../examples/rdf12-triple-term.pl) | Projects an RDF 1.2 triple term into an ordinary relationship. | [`output/rdf12-triple-term.pl`](../examples/output/rdf12-triple-term.pl) |
| [`register-allocation.pl`](../examples/register-allocation.pl) | Allocates temporaries to two registers with spilling by bounded graph-coloring search. | [`output/register-allocation.pl`](../examples/output/register-allocation.pl) |
| [`reusable-builtins.pl`](../examples/reusable-builtins.pl) | Tours reusable numeric, list, and string builtins. | [`output/reusable-builtins.pl`](../examples/output/reusable-builtins.pl) |
| [`riemann-hypothesis.pl`](../examples/riemann-hypothesis.pl) | Checks a finite catalogue of non-trivial zeta zeros against the Riemann-hypothesis condition. | [`output/riemann-hypothesis.pl`](../examples/output/riemann-hypothesis.pl) |
| [`route-planning.pl`](../examples/route-planning.pl) | Finds routes and records them as explicit route terms. | [`output/route-planning.pl`](../examples/output/route-planning.pl) |
| [`sat-solver-dpll.pl`](../examples/sat-solver-dpll.pl) | Searches a CNF formula with DPLL-style recursive decisions and early contradiction pruning. | [`output/sat-solver-dpll.pl`](../examples/output/sat-solver-dpll.pl) |
| [`security-incident-correlation.pl`](../examples/security-incident-correlation.pl) | Correlates security incidents across signals. | [`output/security-incident-correlation.pl`](../examples/output/security-incident-correlation.pl) |
| [`send-more-money.pl`](../examples/send-more-money.pl) | Solves the SEND + MORE = MONEY cryptarithm. | [`output/send-more-money.pl`](../examples/output/send-more-money.pl) |
| [`service-impact.pl`](../examples/service-impact.pl) | Analyzes service impact over cyclic dependencies. | [`output/service-impact.pl`](../examples/output/service-impact.pl) |
| [`shoelace-polygon-area.pl`](../examples/shoelace-polygon-area.pl) | Computes polygon area with a recursive shoelace calculation. | [`output/shoelace-polygon-area.pl`](../examples/output/shoelace-polygon-area.pl) |
| [`sieve.pl`](../examples/sieve.pl) | Enumerates primes with a sieve-style program. | [`output/sieve.pl`](../examples/output/sieve.pl) |
| [`skolem-functions.pl`](../examples/skolem-functions.pl) | Generates deterministic functional terms. | [`output/skolem-functions.pl`](../examples/output/skolem-functions.pl) |
| [`socket-age.pl`](../examples/socket-age.pl) | Shows socket-declared age reasoning inputs and plugs. | [`output/socket-age.pl`](../examples/output/socket-age.pl) |
| [`socket-family.pl`](../examples/socket-family.pl) | Shows socket-declared family-source inputs and ancestry rules. | [`output/socket-family.pl`](../examples/output/socket-family.pl) |
| [`socrates.pl`](../examples/socrates.pl) | Derives that Socrates is mortal. | [`output/socrates.pl`](../examples/output/socrates.pl) |
| [`spacecraft-battery-diagnosis.pl`](../examples/spacecraft-battery-diagnosis.pl) | Combines telemetry, resistive-heating physics, thresholds, and redundant sensing into an evidence-backed diagnosis and safety action. | [`output/spacecraft-battery-diagnosis.pl`](../examples/output/spacecraft-battery-diagnosis.pl) |
| [`stable-marriage.pl`](../examples/stable-marriage.pl) | Finds stable matchings by excluding blocking pairs. | [`output/stable-marriage.pl`](../examples/output/stable-marriage.pl) |
| [`statistics-summary.pl`](../examples/statistics-summary.pl) | Computes population statistics for a sample. | [`output/statistics-summary.pl`](../examples/output/statistics-summary.pl) |
| [`stirling-bell-numbers.pl`](../examples/stirling-bell-numbers.pl) | Computes Stirling numbers and Bell numbers. | [`output/stirling-bell-numbers.pl`](../examples/output/stirling-bell-numbers.pl) |
| [`sudoku-4x4.pl`](../examples/sudoku-4x4.pl) | Solves a compact 4x4 Sudoku by finite constraint search. | [`output/sudoku-4x4.pl`](../examples/output/sudoku-4x4.pl) |
| [`superdense-coding.pl`](../examples/superdense-coding.pl) | Models superdense-coding bit transmission. | [`output/superdense-coding.pl`](../examples/output/superdense-coding.pl) |
| [`symbolic-derivative.pl`](../examples/symbolic-derivative.pl) | Symbolically differentiates explicit expression terms, including products and logs. | [`output/symbolic-derivative.pl`](../examples/output/symbolic-derivative.pl) |
| [`term-tools.pl`](../examples/term-tools.pl) | Inspects, builds, renders, and validates terms with reusable term/control builtins. | [`output/term-tools.pl`](../examples/output/term-tools.pl) |
| [`totient-summatory.pl`](../examples/totient-summatory.pl) | Computes Euler totients and their summatory function. | [`output/totient-summatory.pl`](../examples/output/totient-summatory.pl) |
| [`trust-flow-provenance-threshold.pl`](../examples/trust-flow-provenance-threshold.pl) | Classifies message trust from provenance confidence scores. | [`output/trust-flow-provenance-threshold.pl`](../examples/output/trust-flow-provenance-threshold.pl) |
| [`truth-maintenance-system.pl`](../examples/truth-maintenance-system.pl) | Tracks assumptions, justifications, supported beliefs, and inconsistent environments in a tiny TMS. | [`output/truth-maintenance-system.pl`](../examples/output/truth-maintenance-system.pl) |
| [`type-inference.pl`](../examples/type-inference.pl) | Infers/checks types for a tiny lambda language using logic unification over expression syntax trees. | [`output/type-inference.pl`](../examples/output/type-inference.pl) |
| [`turing.pl`](../examples/turing.pl) | Simulates a binary-increment Turing machine. | [`output/turing.pl`](../examples/output/turing.pl) |
| [`vector-similarity.pl`](../examples/vector-similarity.pl) | Computes dot product, norm, and cosine similarity. | [`output/vector-similarity.pl`](../examples/output/vector-similarity.pl) |
| [`vulnerability-impact.pl`](../examples/vulnerability-impact.pl) | Analyzes vulnerable transitive dependencies and urgent patch impact. | [`output/vulnerability-impact.pl`](../examples/output/vulnerability-impact.pl) |
| [`web-names.pl`](../examples/web-names.pl) | Uses quoted IRI-shaped atoms as first-class web names and joins them across a tiny graph. | [`output/web-names.pl`](../examples/output/web-names.pl) |
| [`weighted-interval-scheduling.pl`](../examples/weighted-interval-scheduling.pl) | Selects the best non-overlapping weighted intervals with automatic tabling. | [`output/weighted-interval-scheduling.pl`](../examples/output/weighted-interval-scheduling.pl) |
| [`witch.pl`](../examples/witch.pl) | Derives the classic “burn the witch” rule chain. | [`output/witch.pl`](../examples/output/witch.pl) |
| [`wolf-goat-cabbage.pl`](../examples/wolf-goat-cabbage.pl) | Solves the wolf-goat-cabbage river crossing. | [`output/wolf-goat-cabbage.pl`](../examples/output/wolf-goat-cabbage.pl) |
| [`workplace-compliance.pl`](../examples/workplace-compliance.pl) | Classifies workplace compliance from explicit action facts. | [`output/workplace-compliance.pl`](../examples/output/workplace-compliance.pl) |
| [`zebra.pl`](../examples/zebra.pl) | Solves the zebra logic puzzle. | [`output/zebra.pl`](../examples/output/zebra.pl) |

## Golden outputs, tests, and conformance

Golden answer outputs live in [`examples/output`](../examples/output). `npm run test:eyepl` covers the eyepl integration check, conformance cases, regression checks, runnable examples, and proof-output examples. A curated proof-output suite for `.pl` examples lives in [`examples/proof`](../examples/proof). Example tests pin `local_time/1` to `2026-05-30` so date-dependent examples stay deterministic. Regenerate them after an intentional output or explanation change:

```sh
for f in examples/*.pl; do
  [ -e "$f" ] || continue
  b=$(basename "$f")
  EYEPL_LOCAL_TIME=2026-05-30 eyepl "$f" > "examples/output/$b"
done

for f in examples/proof/*.pl; do
  b=$(basename "$f")
  EYEPL_LOCAL_TIME=2026-05-30 eyepl --proof "examples/$b" > "examples/proof/$b"
done
```

Run the full Eyepl suite:

```sh
npm run test:eyepl
```

The Eyepl corpus runner runs in this order: Conformance, Regression/API/White-box, Examples. Each section prints its own subtotal, followed by a suite-specific grand total. The suite checks the conformance cases derived from the language reference, supplemental regression/API/white-box checks, and every runnable example against its golden output.

Run only one internal suite when you are iterating:

```sh
node test/run-conformance.mjs
node test/run-regression.mjs
node test/run-examples.mjs
```

Summarize the conformance corpus by category:

```sh
node test/run-conformance-report.mjs
```

Release preparation runs the same report and writes [`conformance-report.md`](../conformance-report.md), so each published package carries a current conformance summary.

The conformance suite lives in [`test/conformance/`](../test/conformance/) as a file-based Eyepl corpus. Positive cases pair `cases/<name>.pl` with exact expected stdout under `expected/<name>.pl`; negative cases pair `errors/<name>.pl` with exact expected error text under `expected-errors/<name>.txt`; warning cases pair `warnings/<name>.pl` with exact `--warnings` stdout and stderr files under `expected-warnings/`; proof cases pair `proofs/<name>.pl` with exact `--proof` output under `expected-proofs/`. Cases may be grouped in category directories such as `arithmetic/`, `strings/`, `lists/`, `terms/`, `atoms/`, `variables/`, `negation/`, and `syntax/`, so another implementation can reuse the same corpus as an executable language contract. The suite covers the standard language surface from the language reference, including reusable built-ins, standard errors, standard warnings, and the machine-readable `why/2` proof-output contract. The regression suite lives in [`test/run-regression.mjs`](../test/run-regression.mjs) and covers CLI regressions, the public JavaScript API, and white-box invariants for parser, unification, and indexing behavior.

## Development and release

Common commands:

```sh
npm run test:eyepl        # alias for npm test
npm test                    # full conformance, regression/API/white-box, examples, and proof examples
node test/run-conformance-report.mjs  # conformance coverage summary by category
node test/run-conformance.mjs
node test/run-regression.mjs
node test/run-examples.mjs
eyepl --help
```

Useful profiling smoke test:

```sh
eyepl -s examples/observability-log-correlation.pl > /dev/null
```

For a release:

1. update `README.md` and the language reference when behavior or public guidance changed;
2. regenerate golden outputs if behavior changed;
3. execute `npm test`;
4. execute npm version with `patch` (or `minor`/`major` as appropriate).

The `preversion` script reruns the full test suite and refreshes [`conformance-report.md`](../conformance-report.md). The version command updates `package.json`, creates the release commit and `v*` tag, and the `postversion` script pushes the commit and tag. The tag triggers the GitHub Release and trusted npm publishing workflows. A push to `main` also deploys the browser playground through GitHub Pages.

## Relationship to Eyeling

[Eyeling](https://github.com/eyereasoner/eyeling) and Eyepl share the same goal of small, inspectable rule-based reasoning in JavaScript, but they make different language and implementation trade-offs.

Eyeling is the RDF/Notation3 member of the family. It reads N3-style triples, quoted formulas, forward rules written with `=>`, backward rules written with `<=`, RDF terms, RDF-JS data, and RDF-oriented streams. That makes it the better fit when data interchange with RDF/N3 tools is the main requirement.

Eyepl is the compact Prolog-style member of the family. It uses ordinary predicate syntax such as `parent(alice, bob).` and `ancestor(X, Z) :- parent(X, Y), ancestor(Y, Z).` The core remains close to the Prolog tradition while deliberately staying smaller and more explicit than ISO Prolog. Its RDF tools provide file interchange through an explicit `rdf/4` adapter, while the language itself remains relational and RDF-agnostic.

A useful rule of thumb:

| Use case | Prefer | Why |
| --- | --- | --- |
| RDF/N3-native rules, quoted formulas, RDF-JS, RDF message streams | Eyeling | The surface language and APIs are RDF/Notation3-native. |
| Standard RDF files with compact relational Eyepl rules | Eyepl | The RDF tools losslessly map RDF 1.2 datasets to ordinary `rdf/4` terms. |
| Compact relational rules over ordinary terms, lists, arithmetic, and finite search | Eyepl | The syntax is shorter for non-RDF relation programs and output is ordinary facts. |
| Human-auditable derivations | Either | Both can emit proof explanations when requested. |
| Large generated Horn-clause workloads | Eyepl | The engine specializes in predicate/arity indexing, scalar argument indexes, fast fact paths, and materialized output goals. |

On local smoke benchmarks, Eyepl is substantially faster on large generated Horn-clause and recursion-heavy workloads. These numbers are 5-run medians with stdout redirected to `/dev/null`, using Node.js `v22.16.0`, Eyepl from this checkout, and Eyeling package version `1.34.6` with its default output mode. The ratio is `Eyeling median / Eyepl median`, so larger numbers mean Eyepl was faster.

| Example | Eyepl median | Eyeling median | Ratio |
| --- | ---: | ---: | ---: |
| `fundamental-theorem-arithmetic` | `0.16 sec` | `2.00 sec` | `12.66x` |
| `deep-taxonomy-100000` | `1.69 sec` | `4.72 sec` | `2.79x` |
| `path-discovery` | `0.53 sec` | `1.62 sec` | `3.07x` |
| `fibonacci` | `0.15 sec` | `5.76 sec` | `38.40x` |
| `collatz-1000` | `0.71 sec` | `6.99 sec` | `9.85x` |

Treat these as smoke comparisons rather than a formal benchmark: hardware, Node.js version, package version, CLI startup, and output mode all matter.

The projects are therefore complementary rather than replacements for each other: Eyeling optimizes for Semantic Web interoperability and N3 expressiveness; Eyepl optimizes for a small standard-looking relational rule language and fast finite goal-directed execution.

## Performance notes

Use `-s` or `--stats` for a quick sanity check while optimizing solver changes. It prints counters such as `solve_goals_calls`, `unify_calls`, `deterministic_rule_expansions`, `candidate_lists_selected`, `clause_candidates_considered`, `clauses_tried`, `max_depth`, and `max_solver_call_depth` to stderr, leaving normal output stable for golden-file tests. The `max_solver_call_depth` counter is especially useful for browser regressions, where the VM call stack can be tighter than a command-line run. Use `-w` or `--warnings` separately when you want portability diagnostics without enabling stricter parsing.

Predicates have compact any-argument scalar indexes. Predicates with fewer than
10 clauses use a linear scan. Larger predicates use an argument index only when it
is estimated to be at least 1.5 times faster than scanning and no more than 10% of
the clauses have variables in that position. A multi-argument index is built on
demand only when it is at least three times better than the best single-argument
choice; rejected combinations are remembered. These defaults follow
[SWI-Prolog's JITI admission policy](https://www.swi-prolog.org/pldoc/man?section=jitindex).
Clauses with variables or structured terms in indexed positions remain candidates,
merged in source order, and unification always performs the final match.

Eyepl hashes predicate groups by name and arity, then indexes clauses by scalar
argument values. Wider indexes follow the bound positions actually encountered
at runtime instead of eagerly allocating every argument combination. This helps
both large generated programs and selective queries such as:

```eyepl
edge(g1, a, X).
path(a, Y).
status(Case, accepted).
```

Ground facts use a fast path that avoids freshening and copying a rule body. Recursive-predicate detection uses an explicit work stack, which keeps large predicate chains safer in the browser. Eyepl automatically tables positive recursive groups, including dependencies reached through supported meta-goals and directly materialized relations. Cyclic calls iterate to an answer fixed point before replay. Recursive components containing a negative dependency retain guarded ordinary resolution because positive fixed-point tabling is not a semantics for unstratified negation. The engine also infers common structurally decreasing input positions; calls with an unbound structural input and fully open calls retain ordinary resolution rather than trying to materialize a potentially infinite relation. Authors do not need a search-control declaration.

Predicates can also carry advisory mode and determinism declarations for documentation and host tooling:

```eyepl
mode(path, 2, [in, out]).
semidet(edge, 2).
```

For large programs, keep helper predicates selective, bind arguments early, document intended calling patterns with `mode/3` when helpful, and declare focused output predicates with `materialize/2` when default output would otherwise solve broad helper goals.

When using `not/1` over user-defined predicates, keep the dependency graph stratified: negative dependencies should not participate in recursion. The CLI option `-w` / `--warnings` prints non-fatal stratification warnings to stderr. The JavaScript API exposes `program.stratifiedNegation`, `program.negationStratificationErrors`, and `program.assertStratifiedNegation()` so host tools can warn or reject programs that rely on unstratified negation. The diagnostic is lazy by default; use `{ analyzeNegation: true }` to compute it during parsing or `{ strictNegation: true }` to compute and reject unstratified programs.

## Implementation limits

Eyepl is intentionally smaller than ISO Prolog. It has no operators, zero-arity compound syntax, cut, modules, dynamic database updates, DCGs, or complete ISO library. Arity-zero data is always written and read back as an atom, such as `nil`, never `nil()`. Negation is negation-as-failure through `not/1`. Search is goal-directed and expected to be finite for the selected output goals. Output explanations are non-normative proof printouts and do not change answer semantics.
