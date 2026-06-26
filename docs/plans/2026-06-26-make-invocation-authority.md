# Make Invocation Authority Plan

Status: Completed

## Goal

Prevent `make check` from reporting success when callers replace the reviewed
npm verification graph, request a non-executing mode, or redirect commands
through caller-selected shell, npm, or root values.

## Root cause

The Makefile rejected a direct `ROOT` override but retained replaceable
single-colon public recipes and a caller-controlled `NPM` variable. A later
single-colon Makefile replaced every verification leaf and returned zero;
`make -n check` also returned zero without executing package or workflow checks.

## Implementation

1. Added a failing causal shell suite for later recipe replacement.
2. Converted public targets to double-colon rules with a shared authority
   prerequisite and runtime `MAKEFILE_LIST` equality guard.
3. Rejected startup files, caller invocation variables, and ten
   non-executing/error-ignoring Make modes.
4. Fixed shell, npm, and repository-root ownership in the reviewed Makefile.
5. Added external-directory and hostile-checkout-path live target checks.
6. Made the authority suite a required prerequisite of `verify` and `check`.

## Verification Completed

- RED: a later single-colon Makefile replaced every verification leaf and
  returned success without running npm or checkout-workflow policy checks.
- `/bin/sh scripts/test-makefile-authority.sh` passed 24 causal authority cases.
- `make check` passed the complete package, parser, build, baseline, audit, and
  checkout-workflow policy gate.
- Absolute external-directory `make -f <repo>/Makefile check` passed.

## Remaining scope

- This boundary proves execution of the reviewed repository graph; it does not
  independently attest the host's `make`, Node, or npm binaries.
