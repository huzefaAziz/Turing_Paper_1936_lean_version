/-!
Formalized core definitions inspired by:
Alan M. Turing (1936), "On Computable Numbers, with an Application to the Entscheidungsproblem".

This file captures a Lean-friendly abstraction of the paper's key notions:
- tape machines (state/symbol transition systems),
- circular vs circle-free behavior,
- computable sequences.

It is intentionally lightweight: it encodes definitions and basic lemmas, not the full
historical proof of undecidability.
-/

namespace Turing1936

open Classical

/-- A simple direction type for single-step head motion. -/
inductive Move where
  | left
  | right
  | stay
deriving DecidableEq, Repr

/--
An abstract deterministic tape machine.

- `State` : internal m-configurations
- `Symbol` : tape alphabet
- `blank` : distinguished blank symbol
- `step` : transition function on `(state, scanned-symbol)`
           returning `(next-state, symbol-to-write, head-move)`
-/
structure Machine where
  State : Type
  Symbol : Type
  blank : Symbol
  step : State → Symbol → (State × Symbol × Move)

namespace Machine

variable (M : Machine)

/--
A complete configuration (in Turing's sense):
- current internal state
- head position (an integer tape index)
- current tape contents (total function `ℤ → Symbol`)
-/
structure Config where
  state : M.State
  head : Int
  tape : Int → M.Symbol

/-- Read the scanned symbol. -/
def scanned (c : M.Config) : M.Symbol :=
  c.tape c.head

/-- Write one symbol at the current head position. -/
def write (c : M.Config) (s : M.Symbol) : M.Config :=
  { c with tape := fun i => if i = c.head then s else c.tape i }

/-- Move the head according to a `Move`. -/
def moveHead (c : M.Config) (mv : Move) : M.Config :=
  match mv with
  | .left => { c with head := c.head - 1 }
  | .right => { c with head := c.head + 1 }
  | .stay => c

/-- One transition step of the machine. -/
def next (c : M.Config) : M.Config :=
  let (q', s', mv) := M.step c.state (M.scanned c)
  let c' := M.write c s'
  let c'' := M.moveHead c' mv
  { c'' with state := q' }

/-- Iterate the machine for `n` steps from an initial configuration. -/
def run : Nat → M.Config → M.Config
  | 0, c => c
  | n + 1, c => run n (M.next c)

/-- A stream of observed output symbols (abstracted as a set of printed times). -/
def prints (outputPred : M.Symbol → Prop) (c0 : M.Config) (n : Nat) : Prop :=
  outputPred ((M.run n c0).tape ((M.run n c0).head))

/--
Circle-free: infinitely many stages at which an output symbol is seen.
This abstracts Turing's notion "prints infinitely many symbols of the first kind".
-/
def CircleFree (outputPred : M.Symbol → Prop) (c0 : M.Config) : Prop :=
  ∀ N : Nat, ∃ n ≥ N, M.prints outputPred c0 n

/-- Circular: not circle-free. -/
def Circular (outputPred : M.Symbol → Prop) (c0 : M.Config) : Prop :=
  ¬ M.CircleFree outputPred c0

/--
A binary stream is computable if there exists some machine and start configuration
whose output at each index agrees with the stream.
-/
def ComputableSequence (f : Nat → Bool) : Prop :=
  ∃ (M' : Machine) (c0 : M'.Config) (isOutput : M'.Symbol → Bool),
    ∀ n : Nat, isOutput ((M'.run n c0).tape ((M'.run n c0).head)) = f n

theorem circular_iff_not_circleFree
    (outputPred : M.Symbol → Prop) (c0 : M.Config) :
    M.Circular outputPred c0 ↔ ¬ M.CircleFree outputPred c0 := by
  rfl

theorem circleFree_has_unbounded_outputs
    (outputPred : M.Symbol → Prop) (c0 : M.Config)
    (h : M.CircleFree outputPred c0) :
    ∀ N : Nat, ∃ n, n ≥ N ∧ M.prints outputPred c0 n := by
  intro N
  rcases h N with ⟨n, hnN, hprint⟩
  exact ⟨n, hnN, hprint⟩

end Machine

/-
Undecidability statements inspired by Sections 8 and 11 are represented axiomatically.
A full derivation requires substantially more infrastructure than this compact file.
-/
axiom no_general_circlefree_decider :
  ¬ ∃ (decideCF : (M : Machine) → M.Config → Bool),
      ∀ (M : Machine) (c0 : M.Config),
        decideCF M c0 = true ↔ M.CircleFree (fun _ => True) c0

axiom entscheidungsproblem_unsolvable : Prop

end Turing1936
