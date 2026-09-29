You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect/reuse existing combat components. Phases 0–3 are complete.

GOAL
Build Marcus's Act I highway combat chapter: a readable linear route through a collapsed elevated highway under wildfire haze.

STORY CONTEXT
Helix patrols and displaced groups fight over supply convoys. Marcus clears a route and finds proof that his former unit has been reassigned to capture Elena.

DELIVERABLES
1. Create scenes/levels/highway_level.tscn with 4 compact arenas connected by short traversal sections. Use stylised placeholder art: cracked asphalt, guardrails, abandoned vehicles, debris, orange haze.
2. Create enemy_enforcer.tscn by reusing combat components. Enforcers have high health, slower movement, predictable block/counter timing, and clear flank/environmental weakness.
3. Create reusable ArenaController: fixed enemy spawn lists/waves, locked exits while active, clear completion condition, checkpoint after successful clear, and no random spawns.
4. Arena progression: Arena 1 introduces scavengers; Arena 2 introduces one enforcer; Arena 3 mixes scavengers/enforcers and throwable objects; Arena 4 combines prior mechanics.
5. Create breakable barricades/barriers using reusable destructible component. Heavy attacks or throws break them. At least one reveals a clear optional shortcut; no critical path may become permanently blocked.
6. Expand throwable environment with pipes, signs, car parts, and one clearly telegraphed fuel canister area effect. Keep outcomes deterministic.
7. Add route-clearing score summary: time, damage, environmental throws, clean-clear bonus. It is feedback only, not a story gate.
8. Add skippable narrative messages at chapter start, between sections, and ending. End with an evidence story flag in GameManager and a Phase 4 completion checkpoint.

ACCEPTANCE CRITERIA
- Every arena can be cleared in a fresh run and after loading a checkpoint.
- Enforcer counter/block pattern is clear and consistent.
- Waves, doors, barriers, optional path, scoring, and story flag work with no softlocks.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 4: highway riots combat complete
