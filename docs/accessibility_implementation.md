# FINAL THAW — Accessibility Implementation Guide

## Standard: Match The Last of Us Part II

Every player must be able to experience the full story, regardless of ability. Accessibility is not optional—it is core to the design from day one.

---

## Visual Accessibility

### Colorblind Modes

**Implementation**:
- Support 12 types: none, deuteranopia, protanopia, tritanopia (each with mild/moderate/severe variants)
- Apply color transformation shader post-process OR sprite palette swaps
- Puzzle indicators must NEVER rely on color alone—add shapes, patterns, or text labels

**Testing**:
- Use colorblind simulation tools (Color Oracle, Sim Daltonism)
- Test all puzzles, UI, enemy telegraphs, environmental hazards
- Get feedback from colorblind gamers during development

---

### UI Scaling

**Implementation**:
- Scale range: 75% - 200% (increments of 25%)
- Apply to ALL UI elements: HUD, menus, dialogue, subtitles, prompts
- Anchor UI properly so it doesn't overlap or clip at high scales
- Test at 75%, 100%, 150%, 200%

**Testing**:
- Verify all text is readable at 200%
- Verify no UI elements are cut off at 200%
- Verify buttons are large enough for motor-impaired players at 200%

---

### High Contrast Mode

**Implementation**:
- Toggle: on/off
- When enabled:
  - UI elements use pure black/white or high-contrast color pairs
  - Interactive objects have bright outlines (yellow/cyan)
  - Background elements are desaturated
  - Text uses bold, high-contrast fonts

**Testing**:
- All critical information visible in high contrast
- No reliance on subtle color differences
- Works with colorblind modes simultaneously

---

### Reduced Motion

**Implementation**:
- Toggle: on/off
- When enabled:
  - Disable camera shake
  - Reduce particle effects by 50%+
  - Disable screen-space effects (bloom, chromatic aberration)
  - Use fade transitions instead of wipes/zooms
  - Reduce weather intensity

**Testing**:
- Players with vestibular disorders can play without discomfort
- No sudden camera movements
- No flashing effects >3 Hz (epilepsy safety)

---

### Reduced Weather Intensity

**Implementation**:
- Options: off, light, medium, heavy (default)
- Controls:
  - Particle density (snow, rain, ash)
  - Post-process blur/distortion from weather
  - Wind audio volume
  - Screen wetness effects

**Testing**:
- Players can see critical gameplay elements through weather
- Performance improves with lower weather settings

---

### Screen Reader Support

**Implementation**:
- All text elements have accessible labels
- Menu navigation announces options via TTS (text-to-speech)
- Dialogue has screen reader option (reads aloud)
- Compatible with OS screen readers (NVDA, JAWS, VoiceOver)

**Testing**:
- Blind players can navigate all menus
- All critical story information available via audio
- Compatible with major screen reader software

---

## Audio Accessibility

### Subtitle Customization

**Options**:
- Size: small, medium, large, extra_large
- Color: white, yellow, cyan, custom picker
- Background: none, dim (50% black), solid (100% black)
- Speaker labels: on/off (e.g., "ELENA:", "MARCUS:")
- Sound effect descriptions: on/off (e.g., "[distant explosion]", "[glass breaking]")

**Testing**:
- Readable at all sizes
- Color choices are actually visible against game backgrounds
- Sound effect descriptions are helpful, not spammy

---

### Visual Sound Cues

**Implementation**:
- Directional indicators for important sounds:
  - Footsteps (enemy, NPC)
  - Gunfire
  - Environmental hazards (falling debris, steam vents)
  - Interactive objects (humming terminals, beeping consoles)
- Display as icons/arrows at screen edges
- Color-coded by type (red = danger, blue = interactable, etc.)

**Testing**:
- Deaf/hard-of-hearing players can locate sound sources
- Cues are clear but not overwhelming
- Works with reduced motion (no flashing)

---

### Audio Description for Cinematics

**Implementation**:
- Optional narrated description of visual-only story moments
- Describes: character expressions, actions, setting changes, text on screen
- Recorded by voice actors OR generated via TTS
- Toggle: on/off

**Testing**:
- Blind players understand full story
- Does not overlap with dialogue (pauses during speech)
- Timing feels natural

---

## Motor Accessibility

### Full Control Remapping

**Implementation**:
- Every input action is remappable
- Support: keyboard, mouse, controller (XInput, DirectInput, Switch Pro)
- Allow multiple bindings per action
- Save profiles (default, custom 1, custom 2)

**Testing**:
- Players can rebind to one-handed layouts
- Controller and keyboard+mouse both fully supported
- No "hardcoded" inputs anywhere

---

### Toggle/Hold Options

**Implementation**:
- For actions that normally require holding:
  - Sprint: hold shift OR toggle
  - Block: hold right-click OR toggle
  - Scan: hold Q OR toggle
  - Aim: hold right-trigger OR toggle
- Each has independent setting

**Testing**:
- Players with limited grip strength can play comfortably
- No action requires sustained pressure

---

### Auto-Run

**Implementation**:
- Toggle: on/off
- When enabled: character walks forward automatically
- Player controls: turning, stopping, interacting
- Speed matches normal walk speed

**Testing**:
- Reduces input burden for exploration sections
- Does not interfere with combat or puzzles (auto-disables if needed)

---

### Aim Assist Levels

**Implementation**:
- Levels: 0% (off), 25%, 50%, 75%, 100%
- Affects: thrown objects, Marcus's ranged attacks (if any)
- Sticky reticle near targets
- Optional auto-throw when aimed at target

**Testing**:
- Players with tremors or limited fine motor control can succeed
- Does not make game trivial at 100% (still requires timing/positioning)

---

### Slow-Motion Mode

**Implementation**:
- Options: off, 0.5x, 0.75x, 1.0x (normal)
- Slows game speed, NOT audio pitch
- Applies to: movement, combat, puzzles, cinematics
- Does NOT affect cutscenes (or optionally does)
- Performance: must maintain 60 FPS even in slow-mo

**Testing**:
- Players with slower reaction times can complete combat/puzzles
- No physics glitches or broken triggers
- Audio remains clear

---

### One-Handed Control Scheme

**Implementation**:
- Pre-configured profile for keyboard or controller
- Keyboard example: WASD (left hand), Space for actions (thumb)
- Controller example: left stick movement, all actions on right buttons
- No sequences requiring simultaneous inputs

**Testing**:
- Full game completable with one hand
- No sequences requiring simultaneous inputs

---

## Cognitive Accessibility

### Puzzle Hint System

**Implementation**:
- Levels: off, contextual, full solution
- **Off**: No hints
- **Contextual**: After 30-60 seconds of inactivity, show subtle hint
- **Full solution**: On request (button press), show complete solution
- Optional: hint cooldown to prevent spam

**Testing**:
- Players can enjoy puzzles without frustration
- Hints are available but not forced
- No penalty for using hints (no achievement locks, etc.)

---

### Extended Time Limits

**Implementation**:
- Toggle: on/off
- When enabled: all timed sections have 2x duration
- Includes: oxygen traversal, vehicle repair, security terminal hacking
- Does NOT affect story pacing (no cutscene extensions needed)

**Testing**:
- Players with slower processing speed can complete timed sections
- Does not break puzzle design (still challenging, just more forgiving)

---

### Objective Marker Always-On

**Implementation**:
- Toggle: on/off
- When enabled: shows arrow/distance to next objective at all times
- Optional: shows distance in meters
- Does not spoil puzzles (only shows "go here", not "solve this way")

**Testing**:
- Players with navigation difficulties don't get lost
- Does not trivialize exploration

---

### Quest Log with Detailed Steps

**Implementation**:
- Always available (pause menu or hotkey)
- Shows: current objective, sub-objectives, optional objectives
- Updates in real-time
- Can be expanded for more detail

**Testing**:
- Players can reference objectives without memorizing
- Clear, jargon-free language

---

### Tutorial Skip/Replay

**Implementation**:
- All tutorials skippable
- All tutorials replayable from options menu
- Tutorial text stays on screen until dismissed (no auto-timeout)

**Testing**:
- Experienced players can skip
- New players can review as needed

---

## Implementation Checklist

### Pre-Production
- [ ] Accessibility designer assigned
- [ ] Disabled gamers consulted for playtesting
- [ ] Accessibility budget allocated (no cutting later)

### Production
- [ ] All visual accessibility features implemented
- [ ] All audio accessibility features implemented
- [ ] All motor accessibility features implemented
- [ ] All cognitive accessibility features implemented
- [ ] Settings menu organized, searchable
- [ ] Default settings are accessible (not "hard mode" by default)

### QA
- [ ] Tested with colorblind gamers
- [ ] Tested with deaf/hard-of-hearing gamers
- [ ] Tested with motor-impaired gamers
- [ ] Tested with cognitively disabled gamers
- [ ] All features documented in manual/options
- [ ] No accessibility feature breaks gameplay

### Post-Launch
- [ ] Accessibility feedback channel open
- [ ] Commitment to fix accessibility bugs within 2 weeks
- [ ] Plan for post-launch accessibility updates

---

## Resources

- **Game Accessibility Guidelines**: https://gameaccessibilityguidelines.com/
- **AbleGamers**: https://ablegamers.org/
- **SpecialEffect**: https://www.specialeffect.org.uk/
- **The Last of Us Part II Accessibility Breakdown**: https://www.youtube.com/watch?v=Hb8w0qFxPQE

---

## Commitment

FINAL THAW will be playable by as many people as possible. Accessibility is not an afterthought—it is core to the design from day one.

No player will be locked out of the story due to disability.
