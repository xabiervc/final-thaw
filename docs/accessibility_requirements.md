# FINAL THAW — Accessibility Requirements (Testable Criteria)

## Purpose

This document defines ACCESSIBILITY REQUIREMENTS that are TESTABLE, not aspirational. Each requirement has a measurable pass/fail criterion. This is not a "nice to have" list—it is a quality gate. If a requirement fails, the game is NOT shippable.

---

## 1. Texto (Size, Escalado, Legibilidad)

### Requirement 1.1: Minimum Text Size

**Criterion**: All UI text must be legible at 10 feet (3 meters) on 1080p display.

**Measurement**:
- Base font size: 16px minimum at 100% UI scale
- X-Large subtitle mode: 32px minimum (200% scale)
- Test: Display text on 24" 1080p monitor, sit 10 feet away. All text must be readable without squinting.

**Pass/Fail**:
- ✅ PASS: All text readable at 10 feet, 100% scale
- ❌ FAIL: Any text requires moving closer or increasing scale

---

### Requirement 1.2: UI Scaling

**Criterion**: Player must be able to scale all UI elements from 75% to 200% without breaking layout.

**Measurement**:
- Options menu: UI Scale slider (75%, 100%, 125%, 150%, 175%, 200%)
- Test: Set to 200%. All text, icons, health bars must fit on screen without clipping.
- Test: Set to 75%. All text must remain legible (not pixelated or too small).

**Pass/Fail**:
- ✅ PASS: All scales work, no clipping, no illegible text
- ❌ FAIL: Any scale causes clipping, overlap, or illegibility

---

### Requirement 1.3: Font Choice

**Criterion**: Font must be sans-serif, high legibility, support extended Latin character set (for localization).

**Measurement**:
- Default font: Noto Sans, Open Sans, or equivalent (sans-serif, x-height ≥50% of cap height)
- Test: Display all characters A-Z, a-z, 0-9, áéíóú, ñ, ç, ü. All must be distinct.

**Pass/Fail**:
- ✅ PASS: All characters distinct, no ambiguity (e.g., I vs. l vs. 1)
- ❌ FAIL: Any character pair ambiguous

---

## 2. Contraste y Modos de Color

### Requirement 2.1: Minimum Contrast Ratio

**Criterion**: All text must meet WCAG AA standard (4.5:1 contrast ratio).

**Measurement**:
- Tool: WebAIM Contrast Checker or equivalent
- Test: Sample all text/background combinations (HUD, menus, subtitles, prompts)
- Minimum: 4.5:1 for normal text, 3:1 for large text (24px+ or 19px+ bold)

**Pass/Fail**:
- ✅ PASS: All combinations meet or exceed 4.5:1
- ❌ FAIL: Any combination below 4.5:1

---

### Requirement 2.2: High Contrast Mode

**Criterion**: High Contrast Mode must make all game elements distinguishable using only luminance (no color reliance).

**Measurement**:
- Mode: Black background (#000000), white text (#FFFFFF), yellow highlights (#FFFF00)
- Test: Enable High Contrast Mode. Play through Phase 2 (laboratory). All interactables, hazards, enemies, collectibles must be distinguishable.
- Test: Colorblind tester (monochrome simulation) must be able to complete game.

**Pass/Fail**:
- ✅ PASS: All elements distinguishable in monochrome
- ❌ FAIL: Any element relies on color alone

---

### Requirement 2.3: Colorblind Modes (12 Types)

**Criterion**: All 12 colorblind types must be able to distinguish hazards, enemies, interactables, and collectibles.

**Measurement**:
- Modes: Deuteranopia, Protanopia, Tritanopia (each with mild/moderate/severe variants) + Achromatopsia (monochrome)
- Test: Enable each mode. Play through Phase 6 (shelter). All hazards (steam, electricity, toxic water) must be distinguishable.
- Alternative: All color-coded elements must have SHAPE or PATTERN distinction (e.g., red hazard = triangle, blue hazard = circle)

**Pass/Fail**:
- ✅ PASS: All 12 modes pass colorblind simulator test
- ❌ FAIL: Any mode fails (color-only distinction)

---

## 3. Subtítulos Configurables

### Requirement 3.1: Subtitle Size Options

**Criterion**: Player must be able to choose subtitle size independently from UI scale.

**Measurement**:
- Options: Small (100%), Medium (150%), Large (200%), Extra Large (250%)
- Test: Set UI scale to 100%, subtitles to Extra Large. Subtitles must be 40px+ (250% of base 16px).

**Pass/Fail**:
- ✅ PASS: Subtitle size independent from UI scale, all 4 options work
- ❌ FAIL: Subtitle size tied to UI scale or any option missing

---

### Requirement 3.2: Subtitle Background

**Criterion**: Subtitles must have configurable background for readability.

**Measurement**:
- Options: None, Semi-transparent black (#80000000), Solid black (#FF000000)
- Test: Enable Solid black. Display subtitles over bright background (white wall, explosion). Text must remain legible.

**Pass/Fail**:
- ✅ PASS: All 3 background options work, text legible in all cases
- ❌ FAIL: Any background option fails legibility test

---

### Requirement 3.3: Subtitle Color

**Criterion**: Player must be able to set subtitle text color.

**Measurement**:
- Options: White, Yellow, Cyan, Green, Custom (RGB picker)
- Test: Set to Yellow. Display over yellow-tinted scene (fire, sunset). Text must remain distinguishable (outline or background required).

**Pass/Fail**:
- ✅ PASS: All color options work, text always distinguishable from background
- ❌ FAIL: Any color option becomes illegible in specific scenes

---

## 4. Identificación de Hablantes

### Requirement 4.1: Speaker Labels

**Criterion**: All dialogue must show speaker name, color-coded consistently.

**Measurement**:
- Format: "[Speaker Name]: Dialogue text"
- Colors: Elena = Cyan (#4A90E2), Marcus = Orange (#E28C4A), Voss = Purple (#9B59B6), NPCs = White (#FFFFFF)
- Test: Play through Phase 8 (first meeting). All dialogue must show speaker names.

**Pass/Fail**:
- ✅ PASS: All dialogue has speaker labels, colors consistent
- ❌ FAIL: Any dialogue missing speaker name or color inconsistent

---

### Requirement 4.2: Off-Screen Indicators

**Criterion**: If speaker is off-screen, subtitle must indicate direction.

**Measurement**:
- Format: "[← Marcus]: Dialogue" (left arrow if speaker is left of camera)
- Test: Elena on-screen, Marcus off-screen left. His subtitle must show left arrow.

**Pass/Fail**:
- ✅ PASS: All off-screen dialogue has directional indicator
- ❌ FAIL: Any off-screen dialogue missing indicator

---

## 5. Indicadores Visuales y Auditivos Redundantes

### Requirement 5.1: Visual Sound Cues

**Criterion**: All critical audio cues must have visual indicator.

**Measurement**:
- Critical sounds: Footsteps, gunfire, alarms, dialogue, explosions, hazard warnings
- Visual: On-screen directional arrow (points to sound source), icon (footprint, bullet, siren, speech bubble, explosion, warning triangle)
- Test: Mute audio. Play through Phase 4 (highway combat). Player must be able to detect all enemy attacks via visual cues alone.

**Pass/Fail**:
- ✅ PASS: All critical sounds have visual equivalent
- ❌ FAIL: Any critical sound has no visual indicator

---

### Requirement 5.2: Audio Description for Cinematics

**Criterion**: All cinematics must have optional audio description track.

**Measurement**:
- Option: "Audio Description" toggle in Accessibility menu
- Content: Narrator describes visual action during dialogue pauses ("Elena turns to Marcus, her face illuminated by terminal glow.")
- Test: Enable Audio Description. Watch Phase 15 (Public Thaw cinematic). All key visual information must be described.

**Pass/Fail**:
- ✅ PASS: All cinematics have audio description, describes all key visuals
- ❌ FAIL: Any cinematic missing description or omits key visuals

---

### Requirement 5.3: Hazard Telegraphs (Multi-Modal)

**Criterion**: All hazards must telegraph via visual AND audio channels.

**Measurement**:
- Example: Steam vent
  - Visual: 1.0 second shadow on ground before eruption
  - Audio: Hissing sound ramps up over 1.0 second
  - Haptic: Controller vibration (if enabled)
- Test: Mute audio, disable haptics. Player must still see telegraph.
- Test: Blindfold test (developer only). Player must hear telegraph.

**Pass/Fail**:
- ✅ PASS: All hazards telegraph via 2+ channels (visual, audio, haptic)
- ❌ FAIL: Any hazard telegraphs via only 1 channel

---

## 6. Remapeo Completo

### Requirement 6.1: Full Control Remapping

**Criterion**: Every input must be remappable to any key/button.

**Measurement**:
- Options menu: "Controls" tab with full key binding list
- Test: Remap ALL inputs to custom layout. Play through Phase 2. All actions must work with new bindings.
- Test: One-handed layout (pre-configured profile). All actions accessible without chorded inputs.

**Pass/Fail**:
- ✅ PASS: All inputs remappable, no hardcoded bindings
- ❌ FAIL: Any input cannot be remapped or requires chorded inputs in one-handed mode

---

### Requirement 6.2: Multiple Profiles

**Criterion**: Player must be able to save up to 5 control profiles.

**Measurement**:
- Options: "Save Profile" button (slots 1-5), "Load Profile" button, "Import/Export" (text code for sharing)
- Test: Create 5 different profiles (one-handed, left-handed, custom, default, accessibility). Save and load each.

**Pass/Fail**:
- ✅ PASS: All 5 slots work, import/export functional
- ❌ FAIL: Any slot fails or import/export broken

---

## 7. Alternativas a Pulsaciones Rápidas

### Requirement 7.1: Toggle vs. Hold

**Criterion**: All hold actions must have toggle alternative.

**Measurement**:
- Actions: Sprint, block, aim, scan, crouch (if added)
- Options: "Toggle Sprint" (on/off), "Toggle Block" (on/off), etc.
- Test: Enable all toggles. Play through Phase 4 (combat). All actions must work without holding any button.

**Pass/Fail**:
- ✅ PASS: All hold actions have toggle alternative
- ❌ FAIL: Any action requires holding button with no toggle option

---

### Requirement 7.2: Input Buffer

**Criterion**: All time-sensitive inputs must have 500ms buffer window.

**Measurement**:
- Example: Dodge input during attack
  - Window: 500ms before impact to 200ms after impact (700ms total)
  - Test: Input dodge 600ms before impact. Must register.
  - Test: Input dodge 300ms after impact. Must register.
- Test tool: Debug overlay showing input timing window.

**Pass/Fail**:
- ✅ PASS: All inputs have ≥500ms buffer
- ❌ FAIL: Any input requires <500ms precision

---

### Requirement 7.3: No Simultaneous Inputs

**Criterion**: No action must require pressing 2+ buttons simultaneously.

**Measurement**:
- Test: All actions (combat, puzzles, switching) must be executable with single button presses.
- Exception: Controller stick press (L3/R3) counts as single input, not chorded.

**Pass/Fail**:
- ✅ PASS: All actions executable with single inputs
- ❌ FAIL: Any action requires simultaneous buttons

---

## 8. Velocidad de Juego Ajustable

### Requirement 8.1: Slow Motion Mode

**Criterion**: Player must be able to set global time scale.

**Measurement**:
- Options: 0.5x, 0.75x, 1.0x (normal), 1.25x (speedrun)
- Test: Set to 0.5x. All gameplay (movement, puzzles, combat, cinematics) must run at 50% speed.
- Test: No gameplay penalty for using slow mode (no achievement lockout, no narrative changes).

**Pass/Fail**:
- ✅ PASS: All speeds work, no penalties
- ❌ FAIL: Any speed breaks gameplay or imposes penalties

---

### Requirement 8.2: Puzzle Timer Extensions

**Criterion**: All timed puzzles must have +50% time option.

**Measurement**:
- Options: "Extended Time" toggle (default: off, enabled: +50% time on all timers)
- Test: Enable Extended Time. Play Phase 6 (oxygen section). Timer must be 90 seconds (not 60).

**Pass/Fail**:
- ✅ PASS: All timers extended by 50% when enabled
- ❌ FAIL: Any timer not extended or extended incorrectly

---

## 9. Dificultad Separada por Componentes

### Requirement 9.1: Component Difficulty Sliders

**Criterion**: Player must be able to adjust difficulty of combat, puzzles, timers independently.

**Measurement**:
- Options: "Combat Difficulty" (0-100%), "Puzzle Hints" (Off/Contextual/Full), "Timer Pressure" (0-100%)
- Test: Set Combat to 25%, Puzzles to 100%, Timers to 50%. Play Phase 4 (combat) and Phase 6 (puzzles). Enemies must deal 25% damage, puzzles unchanged, timers 50% longer.

**Pass/Fail**:
- ✅ PASS: All sliders work independently
- ❌ FAIL: Any slider affects other components or doesn't work

---

### Requirement 9.2: Arena Skip Option

**Criterion**: After 3 deaths in same combat arena, offer skip button.

**Measurement**:
- Test: Die 3 times in Phase 4 Arena 2. "Skip This Arena" button must appear.
- On skip: Narrative adapts ("You found another way around."), no Civilian Aid points, proceed to next arena.

**Pass/Fail**:
- ✅ PASS: Skip appears after 3 deaths, narrative adapts correctly
- ❌ FAIL: Skip missing or narrative doesn't adapt

---

## 10. Guardado Frecuente y Reintentos Razonables

### Requirement 10.1: Checkpoint Frequency

**Criterion**: Checkpoints must be no more than 5 minutes apart (measured by average playtime).

**Measurement**:
- Test: Play through each phase with timer running. Note time between checkpoints.
- Maximum: 5 minutes (300 seconds) between any two checkpoints.

**Pass/Fail**:
- ✅ PASS: All phases have checkpoints ≤5 minutes apart
- ❌ FAIL: Any phase has >5 minutes between checkpoints

---

### Requirement 10.2: Manual Save Anytime

**Criterion**: Player must be able to manual save at any time outside combat.

**Measurement**:
- Input: Pause menu → "Save Game" (any of 10 slots)
- Test: During Phase 2 (puzzle, non-combat), pause and manual save. Reload. All state must persist.
- Test: During Phase 4 (combat), pause. "Save Game" option must be grayed out with tooltip "Cannot save during combat."

**Pass/Fail**:
- ✅ PASS: Manual save works outside combat, correctly disabled during combat
- ❌ FAIL: Manual save fails or works during combat (can cause softlocks)

---

### Requirement 10.3: Death Restart Time

**Criterion**: Time from death to playable character must be <5 seconds.

**Measurement**:
- Test: Die in Phase 4 (combat). Time from death screen to character controllable at checkpoint.
- Maximum: 5 seconds (includes fade-out, load, fade-in).

**Pass/Fail**:
- ✅ PASS: All deaths restart in <5 seconds
- ❌ FAIL: Any death restart takes >5 seconds

---

## 11. Compatibilidad con Teclado, Mando y Asistencia

### Requirement 11.1: Full Keyboard Parity

**Criterion**: All actions possible on controller must be possible on keyboard.

**Measurement**:
- Test: Play through Phases 0-16 using keyboard only (no controller). All actions (movement, interaction, combat, switching, menus) must work.
- Test: All menus navigable with Tab/Enter/Esc (no mouse required).

**Pass/Fail**:
- ✅ PASS: All actions work on keyboard, menus navigable without mouse
- ❌ FAIL: Any action requires controller or mouse

---

### Requirement 11.2: Full Controller Parity

**Criterion**: All actions possible on keyboard must be possible on controller.

**Measurement**:
- Test: Play through Phases 0-16 using controller only (no keyboard). All actions must work.
- Test: All menus navigable with D-pad/A/B (no keyboard required).

**Pass/Fail**:
- ✅ PASS: All actions work on controller, menus navigable without keyboard
- ❌ FAIL: Any action requires keyboard

---

### Requirement 11.3: Assistive Device Compatibility

**Criterion**: Game must work with Xbox Adaptive Controller and equivalent devices.

**Measurement**:
- Test: Connect Xbox Adaptive Controller. Map all inputs to single buttons (no analog required).
- Test: Play through Phase 2 (puzzle) and Phase 4 (combat). All actions must work with digital-only inputs.

**Pass/Fail**:
- ✅ PASS: All actions work with adaptive controller
- ❌ FAIL: Any action requires analog input or force feedback

---

## 12. Pruebas con Usuarios con Distintas Discapacidades

### Requirement 12.1: Colorblind Testers

**Criterion**: At least 3 colorblind testers must complete full game without assistance.

**Measurement**:
- Testers: 1 deuteranopia, 1 protanopia, 1 tritanopia (verified via Ishihara test)
- Test: Each plays through Phases 0-16. No developer hints allowed.
- Metric: All must complete game without getting stuck due to color distinction.

**Pass/Fail**:
- ✅ PASS: All 3 testers complete without color-related stuck points
- ❌ FAIL: Any tester gets stuck due to color distinction

---

### Requirement 12.2: Motor-Impaired Testers

**Criterion**: At least 2 motor-impaired testers must complete full game with accessibility options enabled.

**Measurement**:
- Testers: 1 one-handed player, 1 limited dexterity player (verified via medical documentation or self-report)
- Test: Each plays with one-handed profile + toggle inputs + extended timers. No developer hints.
- Metric: Both must complete game without requiring inputs faster than 1 per second.

**Pass/Fail**:
- ✅ PASS: Both testers complete without requiring rapid inputs
- ❌ FAIL: Any tester requires inputs faster than 1 per second

---

### Requirement 12.3: Hearing-Impaired Testers

**Criterion**: At least 2 hearing-impaired testers must complete full game with audio muted.

**Measurement**:
- Testers: 2 deaf or hard-of-hearing players (verified via audiogram or self-report)
- Test: Each plays with audio muted, subtitles + visual sound cues enabled. No developer hints.
- Metric: Both must complete game without missing critical information due to muted audio.

**Pass/Fail**:
- ✅ PASS: Both testers complete without missing audio-dependent information
- ❌ FAIL: Any tester misses critical information due to muted audio

---

### Requirement 12.4: Cognitive-Impaired Testers

**Criterion**: At least 2 cognitive-impaired testers must complete full game with hints + extended timers enabled.

**Measurement**:
- Testers: 2 players with ADHD, dyslexia, or processing disorders (verified via diagnosis or self-report)
- Test: Each plays with puzzle hints (Full), extended timers (+50%), slow motion (0.75x). No developer hints.
- Metric: Both must complete game without getting stuck on puzzles or timers.

**Pass/Fail**:
- ✅ PASS: Both testers complete without getting stuck
- ❌ FAIL: Any tester gets stuck on puzzle or timer

---

## Summary: Accessibility Test Checklist

| Requirement | Test Method | Pass/Fail | Tester |
|-------------|-------------|-----------|--------|
| **1.1 Minimum text size** | 10 feet, 1080p display | ☐ | Dev |
| **1.2 UI scaling** | 75%-200%, no clipping | ☐ | Dev |
| **1.3 Font choice** | Extended Latin, no ambiguity | ☐ | Dev |
| **2.1 Contrast ratio** | WCAG AA (4.5:1) | ☐ | Dev |
| **2.2 High contrast mode** | Monochrome test | ☐ | Dev |
| **2.3 Colorblind modes** | 12 types, shape/pattern distinction | ☐ | Dev + 3 testers |
| **3.1 Subtitle size** | 4 options, independent from UI | ☐ | Dev |
| **3.2 Subtitle background** | 3 options, legible over bright | ☐ | Dev |
| **3.3 Subtitle color** | 5 options, always distinguishable | ☐ | Dev |
| **4.1 Speaker labels** | All dialogue, color-coded | ☐ | Dev |
| **4.2 Off-screen indicators** | Directional arrows | ☐ | Dev |
| **5.1 Visual sound cues** | Muted playthrough | ☐ | Dev + 2 testers |
| **5.2 Audio description** | All cinematics described | ☐ | Dev |
| **5.3 Hazard telegraphs** | 2+ channels (visual, audio, haptic) | ☐ | Dev |
| **6.1 Full remapping** | All inputs, one-handed profile | ☐ | Dev + 1 tester |
| **6.2 Multiple profiles** | 5 slots, import/export | ☐ | Dev |
| **7.1 Toggle vs. hold** | All hold actions have toggle | ☐ | Dev |
| **7.2 Input buffer** | ≥500ms window | ☐ | Dev |
| **7.3 No simultaneous inputs** | Single-button only | ☐ | Dev |
| **8.1 Slow motion** | 0.5x, 0.75x, 1.0x, 1.25x | ☐ | Dev |
| **8.2 Timer extensions** | +50% on all timers | ☐ | Dev |
| **9.1 Component difficulty** | Independent sliders | ☐ | Dev |
| **9.2 Arena skip** | After 3 deaths | ☐ | Dev |
| **10.1 Checkpoint frequency** | ≤5 minutes apart | ☐ | Dev |
| **10.2 Manual save** | Anytime outside combat | ☐ | Dev |
| **10.3 Death restart** | <5 seconds | ☐ | Dev |
| **11.1 Keyboard parity** | All actions, no mouse | ☐ | Dev |
| **11.2 Controller parity** | All actions, no keyboard | ☐ | Dev |
| **11.3 Adaptive devices** | Xbox Adaptive Controller | ☐ | Dev |
| **12.1 Colorblind testers** | 3 testers, full game | ☐ | External |
| **12.2 Motor-impaired testers** | 2 testers, accessibility options | ☐ | External |
| **12.3 Hearing-impaired testers** | 2 testers, audio muted | ☐ | External |
| **12.4 Cognitive-impaired testers** | 2 testers, hints + extended timers | ☐ | External |

**TOTAL**: 38 requirements, ALL must PASS for game to be shippable.

**This is not optional. This is accessibility as a quality gate.**
