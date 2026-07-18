# Via conformance suite

This directory contains the executable conformance cases for the Via language and reference engine. The normative language description is in the [Via language reference](../../../docs/language-reference.md).

The suite is intentionally file-based so another implementation can run the same programs and compare exact standard output, expected errors, expected warnings, and expected proof output. The conformance corpus is part of the public language contract, not just an implementation smoke test.

All conformance files live under topic directories such as `arithmetic/`, `lists/`, `syntax/`, or `variables/`; new top-level numbered files should not be added. The report uses those directories as coverage categories.

A normal positive case consists of:

- `conformance/cases/<name>.pl` — input program;
- `conformance/expected/<name>.pl` — exact expected standard output, stored as via-readable facts.

Expected-error cases consist of:

- `conformance/errors/<name>.pl` — input program that must fail during parsing or execution;
- `conformance/expected-errors/<name>.txt` — exact expected error message followed by a newline.

Expected-warning cases consist of:

- `conformance/warnings/<name>.pl` — input program run through the CLI with `--warnings`;
- `conformance/expected-warnings/<name>.pl` — exact expected standard output;
- `conformance/expected-warnings/<name>.txt` — exact expected standard error.

Expected-proof cases consist of:

- `conformance/proofs/<name>.pl` — input program run through the CLI with `--proof`;
- `conformance/expected-proofs/<name>.pl` — exact expected standard output, including both answer facts and `why/2` proof facts.

Case names may be nested in category directories such as `arithmetic/`, `strings/`, `lists/`, `terms/`, `atoms/`, `variables/`, `negation/`, or `syntax/`. Expected files mirror the same relative path.

## Running the suite

Run all tests, including conformance, regression, examples, and style checks:

```sh
npm test
```

Run only the conformance suite:

```sh
node test/run-conformance.mjs
```

Summarize conformance coverage by category:

```sh
node test/run-conformance-report.mjs
node test/run-conformance-report.mjs conformance-report.md
```

Run matching conformance cases by passing a filename or directory fragment:

```sh
node test/run-conformance.mjs reusable
node test/run-conformance.mjs 092_scalar_string_conversions
node test/run-conformance.mjs variables/
node test/run-conformance.mjs error/variables
```

The runner executes normal materialized programs in-process through the public JavaScript API so small conformance cases avoid measuring Node startup overhead. Warning and proof cases intentionally use the CLI because warning output and `why/2` proof output are host-interface contracts.

## Scope

The conformance corpus is a single via suite. It covers the standard language described by the language reference: lexical syntax, facts, definite clauses, first-order terms, lists, conjunction, structured unification, left-to-right goal-directed proof search, materialized output, read-back printing, standard built-ins, declarations, warnings, errors, proof output, and standard host behavior.

The suite deliberately does not separate `core` and `extension` profiles. Reusable built-ins such as arithmetic, strings, lists, aggregation, context terms, term inspection, and search control are part of the standard via conformance surface. Implementation-specific built-ins may still exist in downstream hosts, but they should have their own tests outside this corpus unless they are standardized.

## Updating expected output

There is no committed auto-accept mode. To update an expected file, run the matching case with the conformance runner, inspect the result, and replace the corresponding file under `conformance/expected/`, `conformance/expected-errors/`, `conformance/expected-warnings/`, or `conformance/expected-proofs/` deliberately.
