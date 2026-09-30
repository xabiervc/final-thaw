You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect GameManager consequence state, story choices, and all prior systems. Phases 0-14 are complete with award-level foundation through final boss.

**AWARD-LEVEL TARGET**: Endings must match *The Last of Us Part II*, *Spiritfarer*, or *Disco Elysium* emotional impact. Three distinct 90+ second fully voiced cinematics, each with unique visual sequence, musical theme, and narrative closure. Post-credits stinger hooks sequel. Player choice meaningfully determines which ending they receive.

GOAL
Create epilogue, deterministic ending selection, credits, and safe New Game loop.

## ENDING DETERMINATION LOGIC

**EndingResolver function** (`scripts/autoload/ending_resolver.gd`):
```gdscript
func determine_ending() -> String:
    var elena_safety = GameManager.get_elena_safety()
    var prototype_integrity = GameManager.get_prototype_integrity()
    var civilian_aid = GameManager.get_civilian_aid()
    var evidence_choice = GameManager.get_story_flag("evidence_choice")  # "preserve" or "erase"
    
    # Priority 1: Fragile Thaw (sacrifice ending)
    if elena_safety <= 1 or prototype_integrity <= 1:
        return "fragile_thaw"
    
    # Priority 2: Public Thaw (ideal ending)
    if civilian_aid >= 4 and prototype_integrity >= 2 and evidence_choice == "preserve":
        return "public_thaw"
    
    # Priority 3: Guarded Thaw (compromise ending)
    return "guarded_thaw"
```

**Documented thresholds** (in CLAUDE.md and comments):
- **Fragile Thaw**: Elena Safety ≤1 OR Prototype Integrity ≤1 (player sacrificed too much)
- **Public Thaw**: Civilian Aid ≥4 AND Prototype Integrity ≥2 AND Evidence Preserved (ideal run)
- **Guarded Thaw**: All other cases (Helix controls Aster, resistance forms)

**Test hooks** (debug menu, password-protected):
- `force_ending(ending_type: String)`: Set specific ending for QA testing
- `set_all_stats_max()`: Set Safety=3, Integrity=3, Aid=10, Evidence=Preserve
- `set_all_stats_min()`: Set Safety=0, Integrity=0, Aid=0, Evidence=Erase

---

## DELIVERABLES

### 1. Epilogue Scene (`scenes/ui/epilogue.tscn`)

**Structure**:
- **Background**: Dynamic based on ending (Public=clear sky, Guarded=split screen, Fragile=storm clearing)
- **Story cards**: 6 panels, fade in/out sequentially (each 10 seconds)
- **Final statistics**: Display after cards (civilians aided, Safety, Integrity, evidence choice, ending title)
- **Ending title**: Large text (e.g., "PUBLIC THAW" or "GUARDED THAW" or "FRAGILE THAW")
- **Narration**: Voice-over for each card (fully voiced, 90+ seconds total)

**Visual themes**:
- **Public Thaw**: Earth from space, storms receding, green returning, people emerging
- **Guarded Thaw**: Split screen (left=protected zones thriving, right=outside struggling)
- **Fragile Thaw**: Damaged prototype, incomplete stabilization, resilience montage

**Accessibility**:
- Subtitles for all narration (size/color/background customizable)
- Skip button (any input, 2 second delay to prevent misclicks)
- Reduced motion: Fade transitions instead of camera pans

### 2. Ending Cinematics (3 Versions, 90+ Seconds Each)

#### Public Thaw Cinematic

**Visual sequence** (storyboard in comments):
1. **0:00-0:15**: Aster activates. Global map shows stabilization waves spreading (cyan pulses from Final Thaw Station)
2. **0:15-0:30**: Helix facilities opening, data released. Scientists worldwide accessing Aster terminals
3. **0:30-0:45**: Communities rebuilding. Solar panels, vertical farms, water systems. Children playing without masks
4. **0:45-1:00**: Elena at Iris's grave (mountain meadow, flowers): "It's done. The protocol is free. You would have loved this world."
5. **1:00-1:15**: Marcus at police memorial (city, plaque): "I'm not that person anymore. I hope you can forgive me." Places badge.
6. **1:15-1:30**: Global montage—birds returning, first non-toxic snow, sun breaking through clouds

**Final shot**: Elena and Marcus on mountain (same as Final Thaw Station), watching sunrise. No dialogue needed.

**Audio**:
- **Music**: Full orchestra + choir, ascending progression (C major → G major → C major)
- **Leitmotifs**: Elena's theme (piano, strings) + Marcus's theme (brass, percussion) harmonized
- **Ambience**: Birds, wind, distant children laughing

**Narration** (voice-over, fully voiced):
> "The Aster Protocol activated globally. Within months, atmospheric feedback loops reversed. Storms weakened. Temperatures stabilized. Helix, stripped of legitimacy, disbanded. The protocol became public domain—free for any nation, any community, to use and improve. Recovery was not easy. Decades of damage required decades of repair. But for the first time in a generation, spring felt possible. Not guaranteed. But possible."

**Text card** (after narration):
> "The climate stabilized over 17 years. Helix was disbanded. The Aster Protocol became public domain. Recovery was not easy. But it was possible."

---

#### Guarded Thaw Cinematic

**Visual sequence**:
1. **0:00-0:20**: Aster activates. Protected zones bloom immediately (green parks, clean air). Outside: storms continue
2. **0:20-0:40**: Helix checkpoints, ID scans, rationing. "ACCESS DENIED" stamped on civilian applications. Children behind fences
3. **0:40-1:00**: Elena in lab (night, terminal glow): "I saved the climate. But not everyone." Looking at news feed of protests
4. **1:00-1:15**: Marcus training resistance fighters (underground bunker): "They control the cure. We take it back." Loading weapons
5. **1:15-1:30**: Split screen—inside: children in clean park with masks. Outside: same children behind fence, reaching through, no masks

**Final shot**: Elena looking at Aster terminal, hand hovering over button: "I can fix this. I have to."

**Audio**:
- **Music**: Somber strings, unresolved harmony (A minor → E minor, no resolution)
- **Leitmotifs**: Elena's theme (minor key, fragmented), Marcus's theme (distant percussion)
- **Ambience**: Distant sirens, protests, wind

**Narration**:
> "The Aster Protocol activated. But Helix controlled access. Protected zones—corporate enclaves, government facilities, wealthy districts—stabilized immediately. Outside, the storms continued. Rationing began. ID requirements. Means tests. The climate was saved. But who it saved was a different question. Within three years, resistance cells formed. Within five, sabotage campaigns began. Elena Vast disappeared six months after activation. Some say she's still working on a fix. Others say she died trying."

**Text card**:
> "The climate stabilized. But access was controlled. Resistance formed within 3 years. Elena Vast disappeared 6 months later. Some say she's still working on a fix."

---

#### Fragile Thaw Cinematic

**Visual sequence**:
1. **0:00-0:20**: Aster activates partially. Some storms recede, others remain. Incomplete coverage map (50% stabilization)
2. **0:20-0:40**: Communities adapting—some thrive (solar farms, vertical gardens), others struggle (makeshift shelters, rationing)
3. **0:40-1:00**: Elena in medical bay (bandaged, IV drip): "It's not enough. But it's something." Looking at窗外 clearing sky
4. **1:00-1:15**: Marcus distributing supplies (community center): "We make do. We always have." Handing out rations
5. **1:15-1:30**: Montage of resilience—vertical farms in ruins, solar panels on rubble, children learning weather patterns in makeshift school

**Final shot**: Elena and Marcus working side by side (lab, injured but determined). Prototype glowing faintly on table.

**Audio**:
- **Music**: Piano solo, fragile, hopeful but uncertain (C major with suspended 4th, unresolved)
- **Leitmotifs**: Elena's theme (piano only, quiet), Marcus's theme (single brass note, distant)
- **Ambience**: Wind (gentle), machinery hum, children studying

**Narration**:
> "The Aster Protocol activated... partially. Damage to the prototype, to Elena, to the station itself—it was enough. Not enough to fail, but not enough to fully succeed. Storms weakened but did not cease. Temperatures dropped but remained volatile. Communities adapted. Some thrived with the technology they had. Others struggled with what remained. Recovery would take forty years, not seventeen. Elena Vast and Marcus Reyes became symbols—not of victory, but of persistence. Of continuing when continuation itself is the victory."

**Text card**:
> "The climate improved, but not enough. Recovery took 40 years. Elena Vast and Marcus Reyes became symbols—not of victory, but of persistence."

---

### 3. Final Statistics Display

**After cinematic, show**:
```
FINAL STATISTICS

Civilians Aided: [X]/10
Elena Safety: [X]/3
Prototype Integrity: [X]/3
Evidence Decision: [Preserved/Erased]

ENDING: [PUBLIC THAW / GUARDED THAW / FRAGILE THAW]

[Continue to Credits]
```

**Visual**: Clean UI, high contrast, each stat on separate line
**Audio**: Subtle ambient music (no narration during stats)
**Skip**: Any input after 3 seconds (prevents misclicks)

### 4. Credits Scene (`scenes/ui/credits.tscn`)

**Scrolling credits**:
- **Speed**: 50px/second (adjustable in options: slow, normal, fast)
- **Font**: 20px, high contrast (white on black background)
- **Sections**:
  1. Development Team (placeholders: Director, Lead Programmer, Lead Artist, Writer, Composer)
  2. Voice Cast (Elena, Marcus, Voss, supporting)
  3. Advisors (climate scientists, accessibility consultants, sensitivity readers)
  4. Special Thanks (playtesters, community, family)
  5. Technology (Godot Engine, libraries used)
  6. Music Credits (composer, performers, studios)

**Music**: Full soundtrack medley (Elena's theme → Marcus's theme → combined theme), 3-4 minutes

**Skip**: After 30 seconds, any input skips to end (hold 2 seconds to confirm)

**Post-credits**: Fade to black, 2 second pause, then stinger

### 5. Post-Credits Stinger

**Scene** (`scenes/ui/post_credits_stinger.tscn`):

**Visual**:
- Earth from space, 3 years later
- Helix logo on facilities worldwide: crumbling, being removed
- News ticker at bottom: "Aster Protocol now open-source. 147 nations deploying."
- Final shot: Young scientist (new character, 20s, diverse ethnicity) in lab, opening Aster files. Looks at camera.

**Audio**:
- Single piano note, sustained (C5, 5 seconds, fade out)
- Distant news chatter, keyboards typing

**Dialogue** (young scientist):
> "Let's see what we can do better."

**Implication**: Sequel potential, expanded universe, legacy continues

**Duration**: 15 seconds total (not skippable first 5 seconds, then any input to skip)

### 6. New Game Loop

**New Game option** (in MainMenu after credits):
- Calls `GameManager.reset_new_game()`
- Clears all story flags, resets counters to defaults
- Deletes/replaces save file safely (backup old save first)
- Returns to MainMenu (Continue button now disabled)
- Shows toast: "New Game ready. Good luck."

**New Game+** (unlockable after beating all 3 endings):
- Same as New Game, but:
  - Unlocks "Hard Mode" difficulty option
  - Carries over memory fragments collection (can find new ones)
  - Unlocks developer commentary nodes in levels (optional listening)
  - Unlocks concept art gallery in main menu

**Ending-viewed flag**:
- Track which endings player has seen (bitmask: 1=Public, 2=Guarded, 4=Fragile)
- After viewing all 3, unlock New Game+ and achievement "All Endings"

### 7. Accessibility in Epilogue

**Subtitles**:
- Size: Small (16px), Medium (20px), Large (24px), Extra Large (32px)
- Color: White, yellow, cyan (player choice)
- Background: None, semi-transparent black, solid black
- Speaker labels: Always shown, color-coded (Elena=cyan, Marcus=orange, Narrator=white)

**Reduced motion**:
- Fade transitions instead of camera pans
- No scrolling credits (static pages, player advances)
- Stinger: Static shot, no camera movement

**Audio description**:
- Optional narration describing visual action during cinematics
- Example: "Elena turns to Marcus, her face illuminated by terminal glow."
- Toggle per cinematic or always-on

**Screen reader**:
- All text has semantic labels
- Credits readable line-by-line with arrow keys
- Stats display announces each stat on focus

---

## ACCEPTANCE CRITERIA (MUST PASS)

1. **Ending determination**: Same saved inputs always produce same ending. Test with debug force_ending() and manual playthroughs. PASS/FAIL

2. **Fragile Thaw priority**: If Elena Safety ≤1 OR Prototype Integrity ≤1, always Fragile (even if other conditions met). Test edge cases. PASS/FAIL

3. **Public Thaw conditions**: Requires Civilian Aid ≥4 AND Prototype Integrity ≥2 AND Evidence=Preserve. All three must be true. Test with variations. PASS/FAIL

4. **Three cinematics**: Each 90+ seconds, fully voiced, unique visuals, unique music. Time each. Verify voice acting quality. PASS/FAIL

5. **Final statistics**: Displays correctly (civilians, Safety, Integrity, evidence, ending title). Matches GameManager state. PASS/FAIL

6. **Credits**: Scroll at 50px/s (adjustable), all sections present, music medley plays, skip after 30s. Test all options. PASS/FAIL

7. **Post-credits stinger**: 15 seconds, Earth from space, Helix crumbling, young scientist line. Not skippable first 5s. PASS/FAIL

8. **New Game loop**: reset_new_game() clears all flags, resets counters, replaces save safely. MainMenu Continue disabled. PASS/FAIL

9. **New Game+**: Unlocks after all 3 endings viewed. Hard Mode option appears. Developer commentary nodes accessible. PASS/FAIL

10. **Accessibility**: Subtitles (4 sizes, 3 colors, 3 backgrounds), reduced motion (fades, static credits), audio description (optional), screen reader (all text readable). Test all. PASS/FAIL

11. **Performance**: 60 FPS during cinematics (particle effects, camera pans), credits scroll, stinger. Profiler: <5ms per frame. PASS/FAIL

12. **Emotional impact**: Playtest with 10+ external players (no spoilers). 70%+ report "moved" or "emotional" in post-game survey. Document feedback. PASS/FAIL

---

## DO NOT

- Make endings text-only (must be fully voiced cinematics)
- Reuse same cinematic with different text (each ending unique visuals, music, narration)
- Lock player into unskippable sequences (always allow skip after 2-5 seconds)
- Make New Game+ mandatory (optional unlock, not required for completion)
- Forget to test all 3 endings (QA must verify each path)
- Ship without audio description option (accessibility requirement)

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files with descriptions
2. **Test results**: For each acceptance criterion, state PASS/FAIL with evidence (videos, survey results)
3. **Known limitations**: Any unresolved issues, TODOs, technical debt
4. **Performance metrics**: FPS during cinematics, credits, stinger; audio memory usage
5. **Commit message**: Propose this exact message:

```
Phase 15: epilogue and endings complete

Award-level endings with:
- 3 fully voiced cinematics (90+ seconds each, unique visuals, music, narration)
- Public Thaw (Earth recovering, Elena at Iris grave, Marcus at memorial)
- Guarded Thaw (split screen thriving/struggling, resistance forms)
- Fragile Thaw (incomplete stabilization, resilience montage, persistence theme)
- Deterministic ending resolver (Fragile priority, Public conditions, Guarded default)
- Final statistics display (civilians, Safety, Integrity, evidence, ending title)
- Scrolling credits (adjustable speed, soundtrack medley, skip after 30s)
- Post-credits stinger (sequel hook, young scientist, "Let's see what we can do better")
- New Game loop (reset saves, clear flags) and New Game+ (Hard Mode, commentary, gallery)
- Full accessibility (subtitles, reduced motion, audio description, screen reader)

All 12 acceptance criteria PASS. 60 FPS locked. 70%+ playtesters report emotional impact. Ready for Phase 16.
```
