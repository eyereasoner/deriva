# Eyepl

<p align="left">
  <img src="docs/assets/eyepl-logo.png" alt="Eyepl logo" width="70">
</p>

[![npm version](https://img.shields.io/npm/v/eyepl.svg)](https://www.npmjs.com/package/eyepl)
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.21446308-blue.svg)](https://doi.org/10.5281/zenodo.21446308)

Eyepl is a small reasoning language for turning facts and rules into answers and proofs.

The name *Eyepl* evokes movement, wandering, and change—something derived from,
or set in motion by, another source.

Prolog-like syntax. Small core. Inspectable results.

Its default execution is automatically hybrid: ordinary goals use indexed
depth-first resolution, while recursive helper predicate groups are detected
and tabled automatically.

## Install and run

Install the published CLI globally:

```bash
npm install --global eyepl
eyepl --version
printf 'works(stdin, true) :- eq(ok, ok).\n' | eyepl -
```

Eyepl has no runtime npm dependencies and no build step. From a source checkout, run the CLI directly with Node.js 18 or newer:

```bash
node bin/eyepl.js examples/ancestor.pl
node bin/eyepl.js --proof examples/socrates.pl
node bin/eyepl.js --warnings test/conformance/warnings/negation/unstratified_mutual.pl
printf 'works(stdin, true) :- eq(ok, ok).\n' | node bin/eyepl.js -
```

For one-off local CLI use from the checkout, npm can run the package bin without a manual symlink:

```bash
npm exec --yes --package=. -- eyepl --version
npm exec --yes --package=. -- eyepl examples/ancestor.pl
```

To install the checkout's `eyepl` command on your `PATH`, use npm's package link:

```bash
npm link
eyepl --version
```

## STEM showcase: evidence-backed diagnosis

The spacecraft battery example combines sensor telemetry, the physical relation
`P = I²R`, engineering limits, redundant measurements, and causal rules to
derive a diagnosis and safety action:

```bash
node bin/eyepl.js examples/spacecraft-battery-diagnosis.pl
node bin/eyepl.js -p examples/spacecraft-battery-diagnosis.pl
```

The normal output reports computed metrics, a thermal-runaway precursor, and an
`isolate_and_cool` action. With `-p`, every conclusion carries machine-readable
evidence back to telemetry facts, arithmetic operations, threshold comparisons,
and the independent temperature channel.

## JavaScript API

```js
import { run, Program, Solver } from 'eyepl';

const result = run(`
materialize(answer, 1).
answer(ok) :- eq(ok, ok).
`);
console.log(result.stdout);
```

## Documentation

- [Playground](https://eyereasoner.github.io/eyepl/playground)
- [Guide](docs/guide.md)
- [Language reference](docs/language-reference.md)
- [A Compact Reasoning Workbench](docs/compact-reasoning-workbench.md)

For local browser use, serve the checkout first so the playground can load ES modules and example files:

```bash
python3 -m http.server
# then open http://localhost:8000/playground.html
```

## Tests

```bash
npm test
npm run test:conformance
node test/run-conformance-report.mjs
# release preparation writes conformance-report.md via the preversion script
npm run test:examples
npm run test:regression
```
