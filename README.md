# Turing 1936 Lean Formalization

This folder contains:

- `Turing_Paper_1936.pdf`  
  Alan M. Turing, *On Computable Numbers, with an Application to the Entscheidungsproblem* (1936).
- `Turing_Paper_1936.lean`  
  A Lean formalization of core definitions inspired by the paper.

## What is formalized

The Lean file captures a compact, machine-checked model of key ideas:

- A deterministic tape-machine abstraction:
  - `Move`
  - `Machine`
  - `Machine.Config`
- One-step and multi-step execution:
  - `scanned`
  - `write`
  - `moveHead`
  - `next`
  - `run`
- Core semantic notions:
  - `CircleFree`
  - `Circular`
  - `ComputableSequence`
- Basic lemmas:
  - `circular_iff_not_circleFree`
  - `circleFree_has_unbounded_outputs`

## Notes on scope

The original paper contains deep metamathematical arguments (diagonalization, undecidability, and the Entscheidungsproblem result).  
In this Lean file:

- foundational definitions are implemented directly;
- high-level undecidability statements are represented axiomatically:
  - `no_general_circlefree_decider`
  - `entscheidungsproblem_unsolvable`

This keeps the development lightweight and usable as a starting point.

## How to extend this formalization

Suggested next steps:

1. Add a concrete tape encoding (instead of total `Int → Symbol`) with finite support.
2. Define explicit machine examples from the paper (e.g., `010101...`).
3. Replace axioms with proved theorems by building:
   - machine encoding/description-number machinery,
   - a universal machine simulation layer,
   - diagonalization constructions.
4. Connect to mathlib notions for sequences, computability, and logic when helpful.

## Quick usage

Open `Turing_Paper_1936.lean` in Lean 4 environment and check that all declarations compile.  
Then instantiate `Machine` with your own `State` and `Symbol` types to model concrete examples.
