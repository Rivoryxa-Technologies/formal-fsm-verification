# formal-fsm-verification

A small, runnable **formal verification** example: a two-way traffic-light
controller whose safety property (the two directions are never non-red at the
same time) is *proven exhaustively* with model checking, not just tested.

It runs on free, open-source tools: [SymbiYosys](https://github.com/YosysHQ/sby)
(SBY) with Yosys and an SMT solver. No commercial formal tool required.

> **Verified:** the mutual-exclusion property is proven by temporal induction (Yosys + z3); bounded model checking and all cover statements pass.

## Why formal

Simulation shows a design works on the stimulus you happened to write. Formal
proves a property holds for *every* reachable state and input sequence, or hands
you a concrete counterexample. It is how we close the gap that coverage-driven
simulation leaves open, especially on control logic, arbiters, and protocol FSMs.

## What is proven

The properties live in `rtl/traffic_light.sv` under an `ifdef FORMAL` guard:

- **Mutual exclusion (safety):** `ns` and `ew` are never both non-red. Proven by
  unbounded k-induction, so it holds for all time, not just the first N cycles.
- **Legal encoding:** each light is only RED, GREEN, or YELLOW.
- **Reachability (cover):** each green and yellow phase is actually reachable.

## Layout

```
rtl/traffic_light.sv   FSM DUT with formal properties under an ifdef FORMAL guard
traffic.sby            SymbiYosys config: bmc, prove (induction), and cover tasks
```

## Running it

Install the OSS CAD Suite, which bundles Yosys, SymbiYosys, and solvers:
https://github.com/YosysHQ/oss-cad-suite-build/releases

Then:

```bash
sby -f traffic.sby prove    # unbounded safety proof (k-induction)
sby -f traffic.sby bmc      # bounded model check
sby -f traffic.sby cover    # reachability traces
```

The `prove` task should report `PASS`, meaning the mutual-exclusion property is
proven for all reachable states.

## Notes

The DUT is intentionally small so the proof is easy to follow. The same flow
(properties under `ifdef FORMAL`, SBY tasks for bmc, induction, and cover) is
what we apply to real control logic, arbiters, and protocol blocks.

## What Rivoryxa delivers with this

This is our public reference flow for formal verification. On client RTL we apply the same SymbiYosys, Yosys, z3, and abc toolchain at core scale: unbounded proofs that a coverage hole is dead, coverage waivers backed by a z3 checked software invariant, and bug replays that produce a counterexample on the reported RTL and a proof on the fix. Every assert ships paired with a reachability cover so a passing proof is never vacuous, and every run is kept as evidence.

See the [Rivoryxa profile](https://github.com/Rivoryxa-Technologies) for our full service list, or reach us on [LinkedIn](https://www.linkedin.com/company/rivoryxa-technologies/).
