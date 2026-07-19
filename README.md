# Deriva

<p align="left">
  <img src="docs/assets/deriva-logo.png" alt="Deriva logo" width="50">
</p>

[![npm version](https://img.shields.io/npm/v/deriva.svg)](https://www.npmjs.com/package/deriva)
[![DOI](https://zenodo.org/badge/1305066220.svg)](https://zenodo.org/badge/latestdoi/1305066220)

Deriva is a small reasoning language for turning facts and rules into answers and proofs.

The name *Deriva* evokes movement, wandering, and change—something derived from,
or set in motion by, another source.

Prolog-like syntax. Small core. Inspectable results.

Its default execution is automatically hybrid: ordinary goals use indexed
depth-first resolution, while recursive helper predicate groups are detected
and tabled automatically.

## Install and run

Install the published CLI globally:

```bash
npm install --global deriva
deriva --version
printf 'works(stdin, true) :- eq(ok, ok).\n' | deriva -
```

Deriva has no runtime npm dependencies and no build step. From a source checkout, run the CLI directly with Node.js 18 or newer:

```bash
node bin/deriva.js examples/ancestor.pl
node bin/deriva.js --proof examples/socrates.pl
node bin/deriva.js --warnings test/conformance/warnings/negation/unstratified_mutual.pl
printf 'works(stdin, true) :- eq(ok, ok).\n' | node bin/deriva.js -
```

For one-off local CLI use from the checkout, npm can run the package bin without a manual symlink:

```bash
npm exec --yes --package=. -- deriva --version
npm exec --yes --package=. -- deriva examples/ancestor.pl
```

To install the checkout's `deriva` command on your `PATH`, use npm's package link:

```bash
npm link
deriva --version
```

## JavaScript API

```js
import { run, Program, Solver } from 'deriva';

const result = run(`
materialize(answer, 1).
answer(ok) :- eq(ok, ok).
`);
console.log(result.stdout);
```

## Documentation

- [Playground](https://eyereasoner.github.io/deriva/playground)
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
