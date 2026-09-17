# formal-fsm-verification

A small, runnable **formal verification** example: a two way traffic light
controller whose safety property (the two directions are never both off red at the
same time) is proven for every reachable state with model checking, not just tested.

It runs on free, open source tools: [SymbiYosys](https://github.com/YosysHQ/sby)
(SBY), Yosys, and the z3 SMT solver. No commercial formal tool required.

> **Verified on 13 September 2026:** the mutual exclusion property is proven by
> k induction with SymbiYosys, Yosys, and z3. Bounded model checking passes and all
> four cover statements are reached. The full logs from that run are in `logs/`.

## What is proven

The properties live in `rtl/traffic_light.sv` under an `ifdef FORMAL` guard:

- **Mutual exclusion (safety):** `ns` and `ew` are never both off red. Proven by
  k induction, a method that proves the property for every reachable state, not
  just the first N cycles.
- **Legal encoding:** each light is only RED, GREEN, or YELLOW.
- **Reachability (cover):** each green and yellow phase can occur.

## Layout

```
rtl/traffic_light.sv   FSM with formal properties under an ifdef FORMAL guard
traffic.sby            SymbiYosys config: bmc, prove, and cover tasks, engine smtbmc z3
logs/bmc.log           log of the bmc task from the verified run
logs/prove.log         log of the prove task from the verified run
logs/cover.log         log of the cover task from the verified run
```

## Running it

You need SymbiYosys, Yosys, and z3 on your PATH. The
[OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build/releases) bundles all three.

```bash
sby -f traffic.sby prove    # unbounded safety proof (k induction)
sby -f traffic.sby bmc      # bounded model check, depth 20
sby -f traffic.sby cover    # reachability traces
```

Each task ends with `DONE (PASS, rc=0)`. The prove task also prints
`summary: successful proof by k-induction.` and the logs show `Solver: z3`.

## Environment of the verified run

| Tool | Version |
|---|---|
| SymbiYosys | git commit b1a1e98 (YosysHQ/sby, 4 August 2026) |
| Yosys and yosys-smtbmc | 0.67+post (git sha1 b8e7da6f) |
| z3 | 4.16.0 |
| Python | 3.9.6 |
| OS | macOS (Darwin 25.6.0) |

Other versions of these tools should give the same verdicts. Timestamps and file
paths in your logs will differ.

## What this example does not prove

- The design is small, and both outputs are decoded from one state register, so
  the safety property is easy to prove. It shows the method, not a hard proof.
- The run does not assume a reset. The cover checks show each phase is reachable
  from some state, not the full sequence from reset.
- It says nothing about results on a RISC-V core.

## Why formal

Simulation shows a design works on the stimulus you happened to write. Formal
checks a property for every reachable state and input sequence, or hands you a
concrete counterexample. It is most useful on control logic, arbiters, and
protocol state machines.

See the [Rivoryxa profile](https://github.com/Rivoryxa-Technologies) or reach us on
[LinkedIn](https://www.linkedin.com/company/rivoryxa-technologies/).

---

## More from Rivoryxa

This repository is one public example. The method it demonstrates is applied to
real OpenHW CORE-V issues in
[core-v-investigation-reports](https://github.com/Rivoryxa-Technologies/core-v-investigation-reports):
sixteen public GitHub issues taken to a disposition, each with its evidence,
proof scope and limits written down.

All examples are listed on the
[Rivoryxa Technologies profile](https://github.com/Rivoryxa-Technologies).
