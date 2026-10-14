# Phase 1 — Logic contract

Status: agreed logic with review corrections; specification only. Reference model not executed; no Godot or manual validation. Supersedes the electrical rules in MISSION1_GHOST_PROTOCOL.md for the new prototype; the earlier prototype does not implement this contract. Paths remain unchanged.

## Scope

Distribution, protection, diagnostics and archive consultation only. No mission scene, final narrative, protected extraction implementation, containment or save migration.

## Definitive topology

```text
Auxiliary source
|-- Emergency --------------------------------> diagnostic panel
|-- Maintenance switch -----------------------> service lights and platform
`-- Recovery protection --> exclusive selector
                            |-- ENSAYO --------------------> T
                            `-- ARCHIVO --> A --> archive    |
                                            `-- bridge ----> T
                                                             |
                                                     trial isolator
                                                             |
                                                     trial machinery
                                                     start interlock
```

The tampered bridge is fixed. Both machinery feeds converge at T upstream of the isolator. Archive supply leaves A upstream of the isolator. The selector never connects both destinations. This is a deterministic gameplay abstraction, not an electrical simulator.

## State and outputs

Initial: maintenance off, selector ENSAYO, trial connected, recovery protection available, no last recorded trip. ENSAYO and ARCHIVO remain the model's technical identifiers.

Fault present = selector ARCHIVO and trial connected. If protection is available under that condition, it trips immediately. A trip cuts all recovery supply, not emergency diagnostics or maintenance. Opening the isolator or changing destination does not rearm protection. Rearm succeeds only when the fault is absent. Reconnecting trial while ARCHIVO is selected also trips available protection.

Archive stable = protection available AND selector ARCHIVO AND trial isolated. Effective trial supply = protection available AND selector ENSAYO AND trial connected. This explicitly represents selector dependence, even for manually constructed inconsistent test states. Demand recorded before a trip is not effective supply after the trip.

Machinery never starts: its start interlock stays active and cannot be manipulated in this milestone. Maintenance independently powers service lights and enables the platform; its mechanical power-loss behavior belongs to the separate platform test, not this electrical model.

## Operations and history

- set maintenance: only changes maintenance.
- select destination: retains the requested position and evaluates protection.
- set isolated: changes the isolator and evaluates protection.
- rearm: rejects while fault is present without changing positions or history; otherwise makes protection available. Repeated valid rearm is harmless.
- inspect: physically available at the terminal regardless of recovery supply.
- consult: available only with stable archive supply. Reading a clue creates persistent acquired knowledge within the model session. Loss of supply interrupts further consultation but does not erase acquired knowledge. This is not a save-format implementation.
- extract: outside implementation scope; requires stable supply and an external authorization condition still to be defined by scriptwriting. Consultation never implies extraction authorization.

Use the term last recorded trip exclusively for last_trip. It stores the protection-trip reason, not every diagnostic or rejected operation. Correcting, rearming, inspecting and consulting never clear it. Current diagnostic state is derived independently; present both current state and last recorded trip together. No event log is required.

## Diagnostic presentation

Current state priority: protection tripped with fault -> RECOVERY_TRIPPED_FAULT_PRESENT; protection tripped without fault -> RECOVERY_TRIPPED_REARM_PENDING; available with stable archive -> ARCHIVE_STABLE; otherwise -> ARCHIVE_UNPOWERED. Display selected destination separately. last_trip is either null (No trips recorded) or DEMANDA_SIMULTANEA (Simultaneous archive/trial demand recorded). These are proposed diagnostic labels, not final localized UI copy. No message names the control to operate.

## Executable reference and tests

Copy the entire Python block and run with standard Python without optimization (-O disables assert). This is a reference oracle to port to GDScript, not game runtime code or proof of Godot execution. T1-T9 map to the nine agreed cases; X1/X2 are cross-cutting checks. No execution is claimed in this document.

```python
class Circuit:
    def __init__(self):
        self.m = False
        self.d = 'ENSAYO'
        self.i = False
        self.p = True
        self.last_trip = None
        self.knowledge = set()

    def fault(self):
        return self.d == 'ARCHIVO' and not self.i

    def evaluate(self):
        if self.p and self.fault():
            self.p = False
            self.last_trip = 'DEMANDA_SIMULTANEA'

    def maintenance(self, on):
        self.m = on

    def select(self, destination):
        if destination not in ('ENSAYO', 'ARCHIVO'):
            raise ValueError(destination)
        self.d = destination
        self.evaluate()

    def isolate(self, on):
        self.i = on
        self.evaluate()

    def rearm(self):
        if self.fault():
            return False
        self.p = True
        return True

    def outputs(self):
        return dict(diagnostic=True, maintenance=self.m,
                    archive=self.p and self.d == 'ARCHIVO' and self.i,
                    trial=self.p and self.d == 'ENSAYO' and not self.i,
                    machine_running=False)

    def inspect(self):
        if not self.p:
            current = ('RECOVERY_TRIPPED_FAULT_PRESENT' if self.fault()
                       else 'RECOVERY_TRIPPED_REARM_PENDING')
        else:
            current = ('ARCHIVE_STABLE' if self.outputs()['archive']
                       else 'ARCHIVE_UNPOWERED')
        return dict(current=current, destination=self.d,
                    last_trip=self.last_trip)

    def consult(self):
        if not self.outputs()['archive']:
            return False
        self.knowledge.add('REFERENCE_CLUE')
        return True

    def snapshot(self):
        return (self.m, self.d, self.i, self.p, self.last_trip,
                frozenset(self.knowledge))

# T1: initial state and available diagnostics
s = Circuit()
assert s.snapshot() == (False, 'ENSAYO', False, True, None, frozenset())
assert s.outputs() == dict(diagnostic=True, maintenance=False,
                          archive=False, trial=True, machine_running=False)
assert s.inspect() == dict(current='ARCHIVE_UNPOWERED',
                           destination='ENSAYO', last_trip=None)
# T2: selecting archive while connected trips and records cause
s.select('ARCHIVO')
assert not s.p and s.last_trip == 'DEMANDA_SIMULTANEA'
assert not s.outputs()['archive'] and not s.outputs()['trial']
assert s.inspect()['current'] == 'RECOVERY_TRIPPED_FAULT_PRESENT'
# T3: isolation clears fault, not trip latch
s.isolate(True)
assert not s.fault() and not s.p and not s.outputs()['archive']
assert s.inspect()['current'] == 'RECOVERY_TRIPPED_REARM_PENDING'
# T4: successful rearm preserves trip cause in the panel
assert s.rearm() and s.outputs()['archive']
assert s.inspect() == dict(current='ARCHIVE_STABLE',
                           destination='ARCHIVO', last_trip='DEMANDA_SIMULTANEA')
# T5: rejected rearm preserves state and history
t = Circuit(); t.select('ARCHIVO'); before = t.snapshot()
assert not t.rearm() and t.snapshot() == before
# T6: isolate first, select archive: no trip
u = Circuit(); u.isolate(True); u.select('ARCHIVO')
assert u.p and u.outputs()['archive'] and u.last_trip is None
# T7: selecting trial cuts archive; start interlock remains active
u.select('ENSAYO')
assert not u.outputs()['archive'] and not u.outputs()['machine_running']
u.isolate(False)
assert u.outputs()['trial'] and not u.outputs()['machine_running']
# T8: maintenance changes do not affect archive or diagnostics
s.maintenance(True); s.maintenance(False)
assert not s.outputs()['maintenance']
assert s.outputs()['archive'] and s.outputs()['diagnostic']
# T9: repeated valid actions preserve state/history
before = s.snapshot()
for _ in range(10):
    s.isolate(True); s.select('ARCHIVO'); s.maintenance(False)
    assert s.rearm()
    assert s.inspect()['last_trip'] == 'DEMANDA_SIMULTANEA'
assert s.snapshot() == before
# X1: both orders have equal functional endpoints, different histories
v = Circuit(); v.isolate(True); v.select('ARCHIVO')
assert s.outputs() == v.outputs()
assert (s.m, s.d, s.i, s.p) == (v.m, v.d, v.i, v.p)
assert s.last_trip != v.last_trip
# X2: idempotence in initial and tripped states
for tripped in (False, True):
    w = Circuit()
    if tripped: w.select('ARCHIVO')
    before = w.snapshot()
    for _ in range(10):
        w.maintenance(False); w.isolate(False); w.select(w.d)
        assert w.rearm() == (not tripped)
    assert w.snapshot() == before
# Additional: explicit selector dependence, even without evaluate()
for isolated in (False, True):
    w = Circuit(); w.d = 'ARCHIVO'; w.i = isolated
    assert not w.outputs()['trial']
# Additional: reconnecting trial with archive selected trips
v.isolate(False)
assert not v.p and v.last_trip == 'DEMANDA_SIMULTANEA'
# Additional: interrupted consultation preserves acquired knowledge
assert s.consult()
known = s.knowledge.copy()
s.select('ENSAYO')
assert not s.consult() and s.knowledge == known
assert s.inspect()['last_trip'] == 'DEMANDA_SIMULTANEA'
s.select('ARCHIVO')
assert s.consult() and s.knowledge == known
```

## Deduction test and reporting

Schematic: intended distribution. Bridge: physical discrepancy. Indicators: simultaneous demand recorded. Terminal: state verification, never an instruction. Before explicit hints ask which anomaly the player found, why trial must be isolated, and what result they predict. Record actions, clues, hints and explanation. Successful brute force does not establish understanding; do not gate correct operations on mandatory clue reading.

Report separately: inspected; executed (environment, exact command, output); manually validated (observations). Oracle tests do not validate space, persistence, animation or enjoyment. Existing scenes and save contracts remain unchanged.
