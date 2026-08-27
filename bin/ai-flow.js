#!/usr/bin/env node
// The package's entry point, and deliberately nothing more than a way in. The installer is the single
// source of truth for what gets installed and where; a second implementation here would be a copy of its
// file lists, its sweep and its merge, and the copy is what drifts.
//
// The installer detects its own mode from the engine tree sitting beside it, which a package directory
// satisfies, so it needs no argument to know where it is. What it must NOT do is record that directory as
// something to watch later — a package cache can be evicted — and it does not: the condition it records on
// is a git checkout, which this is not.
'use strict';

const { spawnSync } = require('child_process');
const path = require('path');

const installer = path.join(__dirname, '..', 'install.sh');
const argv = process.argv.slice(2);

// The wrapper holds this surface's contract, because it is the only component that knows it IS the npm
// surface. The installer accepts a bare path as a project target for its own back-compat, so forwarding
// argv untouched imported that parse here, where no documented form takes a path: `ai-flow updat` did not
// fail, it created a directory called `updat` and scaffolded a project inside it, reporting success — and
// `ai-flow --help`, the first thing anyone types at a new command, reached `mkdir -p -- --help` and died
// on an error naming neither this tool nor a usage line.
const USAGE = 'usage: ai-flow [init [target] | update]';
const SUBCOMMANDS = ['init', 'update'];
if (argv.length > 0 && (argv[0] === '-h' || argv[0] === '--help')) {
  process.stdout.write(`${USAGE}\n`);
  process.exit(0);
}
if (argv.length > 0 && !SUBCOMMANDS.includes(argv[0])) {
  process.stderr.write(`ai-flow: unknown command "${argv[0]}"\n${USAGE}\n`);
  process.exit(2);
}

const result = spawnSync('bash', [installer, ...argv], { stdio: 'inherit' });

// A missing bash is reported rather than passed off as an installer failure: the two are fixed in
// completely different places, and an exit code alone cannot tell them apart.
if (result.error) {
  const why = result.error.code === 'ENOENT' ? 'bash was not found on PATH' : result.error.message;
  process.stderr.write(`ai-flow: could not run the installer — ${why}\n`);
  process.exit(127);
}

// A signal is not an exit code. Reporting it as one would turn an interrupted install into a numeric
// status the caller reads as a verdict the installer never gave.
process.exit(result.status === null ? 1 : result.status);
