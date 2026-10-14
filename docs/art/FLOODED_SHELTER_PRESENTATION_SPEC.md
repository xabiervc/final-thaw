# Flooded Shelter — UI, VFX and Audio Specification

## Objective

Define the presentation layer for the Flooded Shelter vertical slice: diegetic UI, visual effects, lighting feedback and audio. The goal is to make the existing gameplay loop readable, tense and emotionally coherent without adding visual clutter.

## Design principles

- The HUD is projected by Elena's Aster device.
- UI appears only when relevant and fades when not needed.
- Every critical piece of information must be available through more than one sensory channel.
- Visual feedback must remain readable with reduced motion, high contrast and colorblind modes.
- Audio supports, but never replaces, visual information.

## UI system

### UI-001 — Oxygen meter

- Purpose: show remaining oxygen after valves open.
- Placement: attached visually to the Aster device or lower-left HUD area.
- States:
  - Normal: calm cyan.
  - Warning: amber pulse below 50%.
  - Critical: red pulse below 25%.
  - Empty: red flash and restart/failure feedback.
- Accessibility:
  - Numeric oxygen percentage.
  - Icon plus color change.
  - Optional screen vibration or directional visual cue.
  - Must remain readable at 75–200% UI scale.

### UI-002 — Objective tracker

- Purpose: show current route and progress.
- Route:

```text
POWER -> VALVES -> optional CIVILIAN -> EXIT
```

- States:
  - Incomplete objective: dim outline.
  - Active objective: cyan highlight.
  - Completed objective: check mark and subdued color.
  - Optional objective: distinct “optional” label.
- Accessibility:
  - Text labels, not icons alone.
  - Persistent objective marker option.
  - Quest log entry with detailed steps.

### UI-003 — Interaction prompt

- Purpose: indicate interactable stations.
- Visual:
  - Holographic bracket or ring around the station.
  - `E` key prompt on desktop.
  - Station-specific label: POWER, VALVES, CIVILIAN or EXIT.
- Behavior:
  - Appears when in range.
  - Brightens when focused.
  - Confirms with a short pulse on activation.
  - Fades when out of range.
- Accessibility:
  - High-contrast outline.
  - Colorblind-safe highlight.
  - Text label always present.

### UI-004 — Demo result screen

- Purpose: summarize the player's decisions at the end of the slice.
- Content:
  - Civilian rescued or not rescued.
  - Route completed.
  - Oxygen remaining or failure cause.
  - Narrative consequence line.
  - Continue-to-menu prompt.
- Accessibility:
  - Large readable text.
  - Speaker labels where dialogue appears.
  - Subtitle size, color and background options.

## VFX system

### FX-001 — Water drip

- Trigger: ambient, ceiling leaks and pipe joints.
- Behavior: small droplet particles, occasional splash.
- Density: low; must not distract from gameplay.

### FX-002 — Electrical spark

- Trigger: generator activation and damaged electrical components.
- Behavior: short burst of sparks, brief light flash, then decay.
- Accessibility: pair with audio and a non-color visual cue.

### FX-003 — Dust motes

- Trigger: ambient atmosphere.
- Behavior: slow floating particles in light shafts.
- Must respect reduced-motion setting.

### FX-004 — Valve release

- Trigger: valve activation.
- Behavior: water pressure release, pipe vibration, brief mist burst.
- Must clearly connect the player action to the water-level change.

### FX-005 — Rescue burst

- Trigger: civilian rescued.
- Behavior: soft cyan light pulse, debris displacement and positive UI confirmation.
- Must not obscure the civilian or the exit route.

### FX-006 — Oxygen warning

- Trigger: oxygen below threshold.
- Behavior:
  - HUD pulse.
  - Subtle screen-edge vignette.
  - Audio alarm.
  - Optional controller vibration.
- Must be disableable or reducible for accessibility.

## Lighting design

| Light | Color | Purpose |
|---|---|---|
| Emergency amber | Warm amber | Guides the player through the shelter |
| Aster cyan | Cool cyan | Reinforces Elena's technology and interactive objects |
| Alarm red | Red-orange | Oxygen danger, failure or hazard |
| Ambient fill | Desaturated blue-grey | Prevents pure black areas |
| Exit green | Muted green | Signals successful route completion |

Lighting rules:

- Use flicker sparingly and only on damaged fixtures.
- Avoid strobing.
- Keep interactive stations brighter than surrounding clutter.
- Ensure the player can identify the route without relying exclusively on color.

## Audio design

### Ambience

- Water dripping.
- Distant machinery.
- Structural creaks.
- Low wind or ventilation hum.
- Occasional distant alarm.

### Interaction sounds

| Action | Sound design |
|---|---|
| Generator activation | Mechanical startup, electrical surge, stable hum |
| Valve turn | Metal resistance, ratchet clicks, water release |
| Civilian rescue | Debris movement, human relief, positive UI confirmation |
| Exit door | Heavy mechanism, seal release, route-complete cue |
| UI focus | Soft holographic tick |
| UI confirm | Clear but subtle confirmation tone |

### Oxygen feedback

- Normal: no alarm.
- Warning: slow pulse.
- Critical: faster pulse and rising tension.
- Empty: sharp failure cue followed by silence or room-reset feedback.

### Audio accessibility

- Subtitle size: small, medium, large, extra large.
- Subtitle color: white, yellow, cyan or custom.
- Subtitle background: none, dim or solid.
- Speaker labels: optional.
- Directional sound indicators for footsteps, gunfire, hazards and key interactions.
- Audio description for cinematics.

## Godot implementation notes

- Use `AnimationPlayer`, `AnimationTree`, `AudioStreamPlayer` and GPUParticles3D or CPUParticles3D as appropriate.
- Keep UI in a dedicated CanvasLayer.
- Use themes and scalable font sizes for accessibility.
- Store UI text in the existing localization system.
- Avoid hard-coded English strings.
- Ensure all new systems can be tested headlessly where possible.

## Acceptance criteria

This presentation layer is complete when:

- Oxygen state is understandable without reading a tutorial.
- The player can identify POWER, VALVES, CIVILIAN and EXIT without confusion.
- Every interaction gives visual and audio feedback.
- The result screen clearly communicates consequences.
- UI passes the accessibility requirements for scale, contrast, subtitles and reduced motion.
- A recorded playtest validates the full loop with presentation enabled.
