# FINAL THAW — Vision

## Purpose

This document defines the CORE IDENTITY of Final Thaw: player fantasy, core emotion, pillars, ANTI-PILLARS (what explicitly stays out of scope), target audience, differentiation, and scope. This ensures all team members share the same vision and no structural decisions are made on the fly.

---

## Player Fantasy

### What Fantasy Does the Player Live?

**"I am the scientist and the soldier. I am the thinker and the doer. I am the one who chooses who survives—and who gets left behind."**

The player lives the fantasy of being BOTH:
- **The brilliant scientist** (Elena) who understands the systems, solves the puzzles, and holds the key to saving the world
- **The hardened protector** (Marcus) who fights through the chaos, protects the vulnerable, and makes the hard choices

The fantasy is NOT:
- Being a lone hero who saves everyone (impossible in this game)
- Being a passive observer of climate collapse (player choices matter)
- Being a superhero who never fails (failure is frequent, but teaches)

### Why This Fantasy?

Climate change is not a problem that can be solved by one type of person. It requires BOTH the scientist AND the soldier, BOTH the thinker AND the doer. The player experiences this duality firsthand by switching between Elena and Marcus.

---

## Core Emotion

### What Is the PRIMARY Emotion?

**"Weighted hope."**

The player should feel:
- **The weight** of impossible choices (save 3 civilians or reach the exit before oxygen runs out?)
- **The tension** of environmental threat (steam vents, electrical arcs, toxic water)
- **The relief** of finding shelter, reaching a checkpoint, saving a civilian
- **The hope** that their choices matter (even if the world is burning, they can still save SOMEONE)

The player should NOT feel:
- **Hopelessness** (the world is burning, but player agency matters)
- **Powerlessness** (player has tools: puzzles, combat, switching, choices)
- **Despair** (endings range from Fragile Thaw—imperfect but hopeful—to Public Thaw—free for all)

### Why This Emotion?

Climate change is often portrayed as hopeless ("we're all going to die"). Final Thaw rejects this. The core emotion is "weighted hope": yes, the world is burning, but YOUR choices matter. You can't save everyone, but you can save SOMEONE. That's worth fighting for.

---

## Pillars (What This Game IS)

### Pillar 1: Choices Have Mechanical Consequences

**What It Means**: Every meaningful player decision changes gameplay, not just dialogue.

**Examples**:
- Rescuing 3 civilians in Phase 6: +3 Civilian Aid, +5 minutes, enables Public Thaw ending
- Skipping all rescues: +0 Civilian Aid, faster, locked out of Public Thaw
- Using Aster charge to bypass hazard: -1 charge, faster, safer
- Navigating hazard without charge: risk integrity loss (-1 if hit), slower, no charge spent

**What It Means for Implementation**:
- All choices tracked in GameManager (`civilian_aid`, `evidence_choice`, `elena_safety`, `prototype_integrity`)
- All choices affect endings (Public/Guarded/Fragile thresholds are explicit)
- No "illusion of choice" (all decisions mechanically matter)

---

### Pillar 2: Environment Is Masterable

**What It Means**: Every environmental hazard has a pattern, telegraph, and safe window. Player can LEARN it, OPTIMIZE it, and SPEEDRUN it.

**Examples**:
- Steam vent: 1.0s shadow telegraph, 8s safe window, 2s eruption
- Electrical arc: 0.8s crackle telegraph, 10s cycle, 8s safe window
- Oxygen timer: 60s total, checkpoint at 30s, generous for most players (30-40s completion)

**What It Means for Implementation**:
- All hazards have fixed cycles (no randomness)
- All hazards have visible/audible telegraphs (1.0-1.5s warning)
- All hazards have safe windows (player can learn and optimize)
- No "gotcha" hazards (nothing instant-death without warning)

---

### Pillar 3: Dual-Protagonist Is Core

**What It Means**: Elena and Marcus are NOT interchangeable. Elena = puzzle mastery, Marcus = combat mastery. Switching reflects growing trust (2s cooldown early → instant late-game).

**Examples**:
- Elena cannot attack enemies (must switch to Marcus or avoid combat)
- Marcus cannot hack terminals (must switch to Elena or find alternate route)
- Phase 12 Room 1: Elena hacks terminal (10s) while Marcus defends (3 waves)
- Phase 12 Room 3: Elena controls lighting (3 switches) while Marcus performs stealth takedowns

**What It Means for Implementation**:
- Elena has NO attack abilities (verified in tests: `test_elena_cannot_combat`)
- Marcus has NO hack abilities (verified in tests: `test_marcus_cannot_puzzles`)
- Switching is mandatory for synergy rooms (verified in tests: `test_synergy_requires_both`)
- Switching cooldown decreases as trust grows (2s in Phase 8, instant in Phase 12+)

---

### Pillar 4: Failure Teaches, Doesn't Punish

**What It Means**: Death or failure sets player back 3-5 minutes maximum, never 30+ minutes. Checkpoints are generous. Collectibles persist through death.

**Examples**:
- Death: Restart at last checkpoint (3-5 min back), collectibles persist
- Timer expiry: Narrative adapts ("You fixed it, but barely"), no game over
- 3 deaths in same arena: "Skip this section" button appears (narrative adapts, no Civilian Aid)

**What It Means for Implementation**:
- All checkpoints ≤5 minutes apart (verified in tests: `test_checkpoint_spacing`)
- All collectibles persist through death (verified in tests: `test_collectible_persistence`)
- All timer failures adapt narrative (no game over, just penalty)
- Skip option after 3 deaths (verified in tests: `test_skip_option`)

---

## Anti-Pillars (What This Game IS NOT)

### Anti-Pillar 1: No Survival Porn

**What It Means**: Climate collapse is the CONDITION, not the SPECTACLE. We do NOT show suffering for shock value.

**What Stays Out**:
- No body counts (no "1 million died in Jakarta floods" text)
- No graphic death scenes (Iris died off-screen, we only see Elena's guilt)
- No "climate porn" (no lingering shots of burning cities, drowned skyscrapers)

**Why**: This game is about AGENCY, not despair. We show the CONSEQUENCES of climate collapse (hazards, scarcity, displacement), but we don't exploit suffering for emotional manipulation.

---

### Anti-Pillar 2: No White Savior Narrative

**What It Means**: Elena and Marcus HELP communities, but communities save THEMSELVES. Player choices enable local resilience, not top-down salvation.

**What Stays Out**:
- No "Elena single-handedly saves the world" ending (Public Thaw = protocol is FREE, communities deploy it themselves)
- No "Marcus rides in on white horse" moments (Marcus protects evacuees, but evacuees organize their own resistance)
- No "privileged zones thrive, everyone else dies" binary (Guarded Thaw = controlled access, but resistance forms; Fragile Thaw = incomplete but hopeful)

**Why**: Climate justice is not about individual heroes. It's about collective action. Elena and Marcus are CATALYSTS, not saviors.

---

### Anti-Pillar 3: No Techno-Utopianism

**What It Means**: Aster is a TOOL, not a MAGIC WAND. Deploying Aster doesn't fix everything—it creates NEW choices and NEW consequences.

**What Stays Out**:
- No "Aster fixes climate, everyone cheers" ending (Public Thaw = protocol is free, but recovery takes 17 years, not easy)
- No "Helix is evil, Elena is good" binary (Voss is Elena's mentor, believes she's right, has tragic backstory)
- No "technology saves us, no behavior change needed" message (player choices—rescues, evidence, protection—matter more than Aster itself)

**Why**: Technology is not a panacea. It's a tool that can be used for good OR control. The game asks: "Who controls the cure?" not "Does the cure exist?"

---

### Anti-Pillar 4: No Randomness in Critical Systems

**What It Means**: No random critical hits, no RNG damage, no random hazard patterns. All critical systems are deterministic and masterable.

**What Stays Out**:
- No random enemy crits (all damage is fixed: 10-50 based on enemy type)
- No random hazard patterns (all hazards have fixed cycles: 10s loop, 8s safe window)
- No random resource spawns (all resources are placed by level designers, verified in tests)

**Why**: Randomness undermines mastery. If player dies to RNG, they learn nothing. If player dies to their own mistake, they learn and improve.

---

## Target Audience

### Primary Audience

**Who**: Players who enjoyed *The Last of Us*, *Disco Elysium*, *Hades*, *Portal 2*

**Why**: These games share Final Thaw's DNA:
- *The Last of Us*: Dual-protagonist narrative, moral choices, environmental threats
- *Disco Elysium*: Meaningful choices, consequences, no "correct" answer
- *Hades*: Masterable combat, fair difficulty, failure teaches
- *Portal 2*: Masterable puzzles, teach-test-twist structure, environmental mastery

**Age**: 16+ (climate themes, violence, moral complexity)

**Platform**: PC (Steam), Steam Deck (primary), consoles post-launch

---

### Secondary Audience

**Who**: Climate-conscious players, narrative game fans, accessibility advocates

**Why**: These audiences are underserved:
- Climate-conscious players: Most climate games are either depressing (no agency) or preachy (no gameplay)
- Narrative game fans: Most narrative games are either walking simulators (no mechanics) or choice-fatigue (too many branches, no consequences)
- Accessibility advocates: Most games have accessibility as an afterthought; Final Thaw has 38 testable requirements

---

## Differentiation

### How Is Final Thaw Different from Similar Games?

| Game | Similarity | Differentiation |
|------|------------|-----------------|
| **The Long Dark** | Climate survival | Final Thaw: Dual-protagonist, puzzles + combat, meaningful choices (not just survival calculus), 3 distinct endings |
| **Subnautica** | Environmental threats, exploration | Final Thaw: Fixed hazards (no RNG), narrative-driven (not sandbox), consequences affect endings (not just survival) |
| **Frostpunk** | Climate governance, moral choices | Final Thaw: Personal scale (Elena + Marcus, not city management), real-time (not turn-based), dual-protagonist (not single ruler) |
| **Death Stranding** | Environmental traversal, dual-protagonist vibes | Final Thaw: Tighter scope (13-15 hours, not 40+), more frequent checkpoints (3-5 min, not 30+), clearer consequences (3 endings, not binary) |

### Unique Selling Points

1. **Dual-protagonist design**: Not just aesthetic—Elena and Marcus have fundamentally different gameplay requiring different mastery.
2. **Consequence counters**: Visible, persistent tracking of Elena Safety, Prototype Integrity, Civilian Aid. Player always knows ending eligibility.
3. **Meaningful moral choices**: Not "good vs. evil" but "what kind of good?" (Public Thaw = free for all but harder; Guarded Thaw = controlled but stable; Fragile Thaw = imperfect but hopeful).
4. **Environmental hazards as puzzles**: Steam vents have patterns, electrical hazards have safe windows, flooding has controllable pumps/valves. Player can MASTER environment, not just endure.
5. **Tight checkpointing**: No 2-hour survival marathons. Failure = 3-5 minute setback, not "restart the entire day."

---

## Scope

### What's In Scope (v1.0)

**Campaign**: 16 phases, 3 acts, 13-15 hours (novice), 8-10 hours (competent), 5-6 hours (expert)

**Platforms**: Windows PC (primary), Steam Deck (verified), macOS/Linux (post-launch if resources allow)

**Languages**: English (base), Spanish (ES), French (FR), German (DE), Portuguese (PT-BR), Russian (RU)

**Accessibility**: 38 testable requirements (all must PASS for shippable)

**Content**: 24 memory fragments, 8-10 civilian rescues, 3 endings (Public/Guarded/Fragile), New Game+ (Easy/Hard modes, chapter select, developer commentary)

---

### What's Out of Scope (v1.0)

**Campaign**: No DLC, no sequel hooks (post-credits stinger is optional flavor, not setup)

**Platforms**: No PlayStation/Xbox/Switch (post-launch ports only if v1.0 succeeds)

**Languages**: No Japanese, Chinese, Korean, Italian (post-launch if resources allow)

**Accessibility**: No eye-tracking, no brain-computer interface (nice-to-have, not core)

**Content**: No romance subplot, no crafting system, no open world, no base building (all cut per Non-Negotiable Pillars)

---

## Duration Target

**Target**: 13-15 hours (novice first playthrough), 8-10 hours (competent second playthrough), 5-6 hours (expert/speedrun)

**Justification**:
- **Pacing**: 3 acts, 13 playable chapters, 4 inflection points—enough time for character arcs to land emotionally, not so long that middle chapters feel padded
- **Replayability**: 3 endings, New Game+, collectibles (24 memories, 8-10 rescues)—encourages multiple runs without bloating first run
- **Industry benchmark**: *Hades* (15-20 hours, tight, no filler), *Spiritfarer* (15-20 hours, emotional, some fetch quests)—Final Thaw targets 13-15 hours (shorter than competitors, respects player time)

---

## Sign-Off

**Lead Designer**: [ ] Vision aligns with design pillars, anti-pillars enforced
**Lead Writer**: [ ] Vision aligns with narrative (weighted hope, no white savior, no techno-utopianism)
**Lead Programmer**: [ ] Vision feasible within technical constraints (60 FPS, <2s loads, ≤5-8 GB memory)
**Accessibility Lead**: [ ] Vision accessible (38 requirements, no "skill gate" that excludes disabled players)
**Producer**: [ ] Vision feasible within scope (13-15 hours, 6 languages, PC + Steam Deck)

**Date**: September 30, 2026
**Status**: ✅ VISION COMPLETE. PLAYER FANTASY, CORE EMOTION, PILLARS, ANTI-PILLARS, AUDIENCE, DIFFERENTIATION, SCOPE, DURATION DEFINED.
