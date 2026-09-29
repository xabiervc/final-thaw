# FINAL THAW — Continuity Checklist

Use this checklist before committing any narrative or gameplay change that touches story state, dialogue, or endings.

## Character Continuity

- [ ] Elena's dialogue remains precise, concrete, and non-melodramatic.
- [ ] Marcus's dialogue remains direct, with dry humor only under pressure.
- [ ] Neither protagonist contradicts their established arc without explicit justification.
- [ ] The Helix Commander remains procedurally calm until near defeat.

## Timeline and Location Continuity

- [ ] Phase order matches `config/chapter_config.json`.
- [ ] Climate conditions per location match `data/locations.json`.
- [ ] No location appears out of act order (e.g., port before shelter).
- [ ] Weather escalation in Final Thaw Station follows: snow → blizzard → extreme storm.

## Consequence Continuity

- [ ] Elena Safety changes only via clearly telegraphed joint-mission threats.
- [ ] Prototype Integrity changes only via explicit prototype hazard events.
- [ ] Civilian Aid increments once per defined rescue objective.
- [ ] Evidence Choice in Phase 13 overwrites Phase 12 intention.

## Ending Consistency

- [ ] Fragile Thaw has priority if `elena_safety <= 1` OR `prototype_integrity <= 1`.
- [ ] Public Thaw requires `civilian_aid >= 4`, `prototype_integrity >= 2`, and `evidence_choice == preserve`.
- [ ] Guarded Thaw applies otherwise.
- [ ] No hidden variables affect the ending.

## Dialogue and Text

- [ ] All story text is skippable and does not block gameplay.
- [ ] No text promises mechanics or outcomes that do not exist.
- [ ] Endings do not claim instant global healing; they describe slowed collapse and political conditions.
- [ ] Proper nouns are consistent: Aster Protocol, Final Thaw Station, Helix Consortium.

## Save/Load Integrity

- [ ] Reloading a save cannot duplicate Civilian Aid increments.
- [ ] Corrupt or missing save files do not crash the game.
- [ ] Evidence Choice persists correctly after load.

## Cross-Phase Consistency

- [ ] References to earlier events (e.g., shelter rescue, port aid) match what actually happened in the player's run.
- [ ] No phase assumes knowledge the player could not have at that point.
- [ ] Act-turn summaries in `docs/act_outline.md` remain accurate after any change.

## Before Release

- [ ] Run through all three ending paths using documented test states.
- [ ] Verify that each ending text matches the computed ending_key.
- [ ] Confirm that no release build exposes internal counters in a confusing way.
