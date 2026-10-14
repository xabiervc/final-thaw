# Flooded Shelter — UI, VFX and Audio Specification

## Objective

Define the presentation layer for the Flooded Shelter vertical slice: diegetic UI, visual feedback, environmental effects and audio requirements. These systems must support the existing gameplay loop without obscuring navigation or interaction.

## UI direction

The HUD is projected by Elena's Aster device. It should feel like a lightweight holographic interface, not a conventional game HUD.

- Shape language: thin lines, rounded rectangles, technical brackets.
- Primary color: cyan.
- Secondary color: pale white.
- Warning color: amber.
- Failure color: red-orange.
- Avoid opaque full-screen panels during gameplay.
- All critical information must remain readable with high-contrast mode and 75–200% UI scaling.

## HUD elements

### UI-001 — Oxygen meter

- Location: near the Aster device or upper-left screen area.
- States: normal, warning, critical, depleted.
- Normal: cyan fill, stable display.
- Warning: amber pulse below 40%.
- Critical: red-orange pulse below 20%, increased pulse rate.
- Depleted: screen fade or restart feedback, according to current gameplay rule.
- Accessibility: numeric percentage optional; color must not be the only signal.

### UI-002 — Objective tracker

- Location: upper-center or upper-right.
- Route: POWER, VALVES, optional CIVILIAN, EXIT.
- States: current, complete, optional, failed/skipped.
- Current objective: brightest and animated.
- Completed objective: dimmed with check state.
- Optional objective: visually distinct but not mandatory-looking.

### UI-003 — Interaction prompt

- Trigger: player near an interactable station.
- Content: action verb plus input glyph.
- Examples: `Activate generator [E]`, `Open valves [E]`, `Rescue civilian [E]`, `Exit shelter [E]`.
- Feedback: station highlight, prompt scale-in, confirmation pulse on activation.
- Accessibility: prompt must be readable without relying on color alone.

### UI-004 — Demo result screen

- Trigger: player exits after completing the route.
- Content: route completed, civilian rescued or not rescued, oxygen remaining, consequence summary.
- Tone: restrained, narrative, non-punitive.
- Actions: continue, return to main menu.
- Localization: all strings must use `NarrativeTextManager` ES/EN workflow.

## VFX requirements

| ID | Effect | Trigger | Requirements |
|---|---|---|---|
| FX-001 | Water drip | Ceiling leaks and damaged pipes | Small, looping, cheap particle effect |
| FX-002 | Electrical spark | Generator activation or damaged machinery | Short burst, cyan-white core, no screen obstruction |
| FX-003 | Dust motes | Ambient atmosphere | Slow drifting particles, subtle depth cue |
| FX-004 | Valve water release | Valves opened | Directional water burst or flow increase |
| FX-005 | Rescue pulse | Civilian rescued | Soft cyan pulse around civilian and station |
| FX-006 | Oxygen warning | Oxygen below threshold | HUD pulse plus optional vignette; must respect reduced-motion setting |
| FX-007 | Exit unlock | Route complete | Door highlight and brief energy sweep |

## VFX performance rules

- Prefer GPU particles and simple shaders.
- Avoid full-screen post-processing during normal gameplay.
- Limit simultaneous high-cost particle systems.
- All VFX must have a reduced-intensity variant or be disabled by the reduced-motion accessibility option.
- VFX must not hide enemies, interaction prompts or navigation routes.

## Audio requirements

### Ambience

| ID | Sound | Purpose |
|---|---|---|
| AUDIO-001 | Shelter ambience | Water drips, distant machinery, structural creaks |
| AUDIO-002 | Water flow | Changes when valves open |
| AUDIO-003 | Emergency light hum | Subtle electrical atmosphere |
| AUDIO-004 | Wind or distant collapse | External threat and isolation |

### Interaction

| ID | Sound | Trigger |
|---|---|---|
| AUDIO-005 | Generator startup | POWER station activated |
| AUDIO-006 | Valve turn | VALVES station activated |
| AUDIO-007 | Water release | Valve completion |
| AUDIO-008 | Civilian rescue | CIVILIAN station completed |
| AUDIO-009 | Exit unlock | Route completed |
| AUDIO-010 | UI confirm | Interaction accepted |
| AUDIO-011 | UI deny | Interaction unavailable |

### Oxygen

| ID | Sound | Trigger |
|---|---|---|
| AUDIO-012 | Oxygen warning | Below 40% |
| AUDIO-013 | Oxygen critical | Below 20% |
| AUDIO-014 | Oxygen depleted | Restart or failure state |

## Audio mixing rules

- Dialogue and critical UI cues must remain audible over ambience.
- Ambience should duck slightly during interaction feedback.
- Oxygen warnings must escalate without becoming painful or repetitive.
- Music is optional in this slice; if present, it must not compete with water, machinery or UI cues.
- All audio must have a visual or gameplay equivalent for deaf and hard-of-hearing players.

## Accessibility requirements

- Oxygen state must be communicated through color, motion, number or icon, not color alone.
- Directional audio cues require optional visual indicators.
- Subtitles must support size, color and background options.
- Reduced motion must reduce or disable camera shake, heavy particle motion and pulsing effects.
- All interaction prompts must be remappable.

## Acceptance criteria

The presentation layer is complete when:

- The player can understand POWER, VALVES, CIVILIAN and EXIT without external explanation.
- Oxygen state is immediately readable.
- Interactions provide clear audiovisual feedback.
- UI remains legible at minimum and maximum scale.
- VFX and audio respect accessibility settings.
- The scene remains performant with all systems active.
