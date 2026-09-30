You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and inspect GameManager consequence state and story choices. Phases 0–14 are complete with professional-grade foundation.

GOAL
Create the epilogue, deterministic ending selection, credits, and a safe New Game loop. Design with award-quality narrative presentation, clarity, and accessibility.

ENDING RULES (document exact thresholds in code and UI/debug documentation)
- Fragile Thaw has priority if elena_safety <= 1 OR prototype_integrity <= 1
- Otherwise Public Thaw if civilian_aid >= 4 AND prototype_integrity >= 2 AND evidence_choice == "preserve"
- Otherwise Guarded Thaw

QUALITY STANDARDS
- Same saved inputs always result in same ending (deterministic)
- Priority rule for Fragile Thaw works correctly
- Credits and New Game do not trap player or leave old consequence state
- All epilogue text and buttons function without errors
- Accessibility: clear visual indicators, skippable credits, text size options

DELIVERABLES

1. Create scenes/ui/epilogue.tscn with:
   - Readable story cards or scenes (3–5 cards depending on ending)
   - Clearing-weather presentation (stylised sky clearing, storm diminishing)
   - Placeholder character/environment art (silhouettes, icons, or simple scenes)
   - High contrast, readable text
   - Clean, professional layout
   - Clear ending title (e.g., "ENDING: PUBLIC THAW")

2. Implement one EndingResolver function/resource (scripts/components/ending_resolver.gd):
   - Applies rules above deterministically
   - Testable: can call with mock GameManager state and verify output
   - Returns named ending key: "fragile_thaw", "public_thaw", or "guarded_thaw"
   - Well-commented with rule documentation
   - Debug mode to test all three endings

3. Implement concise narrative content for each ending (2–4 cards per ending):

   Public Thaw:
   - "The Aster Protocol activates. Storms weaken. Atmospheric feedback slows."
   - "Communities receive the stabilisation data. Helix loses public legitimacy."
   - "Elena and Marcus release the protocol openly. Recovery begins, not as a commodity, but as a shared resource."
   - "The world does not heal instantly. But for the first time in years, spring feels possible."

   Guarded Thaw:
   - "The Aster Protocol activates. Climate collapse slows."
   - "But Helix controls access to recovery technology. Protected zones thrive; others remain vulnerable."
   - "Elena's data is proprietary. Marcus's defection is classified."
   - "The world stabilises, but the question remains: stability for whom?"

   Fragile Thaw:
   - "The Aster Protocol activates imperfectly. Storms weaken but do not cease."
   - "Elena is injured. The prototype is damaged. Recovery is possible, but harder."
   - "Helix retains control. Communities must rebuild with limited resources."
   - "Survival remains possible. But the cost was high, and the compromises ahead are harder."

   - All text skippable and readable at player pace
   - Clear, professional typography
   - Optional voiceover placeholders (if added later)

4. Show clear final statistics:
   - Civilians aided (0–10)
   - Elena Safety (0–3)
   - Prototype Integrity (0–3)
   - Final evidence decision (Preserve or Erase)
   - Ending title (e.g., "ENDING: PUBLIC THAW")
   - Clear, readable UI with good contrast
   - Optional: playtime, deaths, or other stats

5. Create scrolling credits (scenes/ui/credits.tscn):
   - Placeholders for developer names (e.g., "Developed by [Your Name]", "Design by...", "Programming by...", etc.)
   - Thank-you section (e.g., "Thank you for playing FINAL THAW")
   - Skippable after short delay (e.g., 3s, or press any button to skip)
   - Clear, readable text with good contrast
   - Optional: background music or ambient sound
   - Performance optimized (no lag during scroll)

6. Add New Game option:
   - Calls GameManager.reset_new_game()
   - Clears/replaces save safely (no old state left behind)
   - Returns to new start flow (MainMenu or directly to Phase 0)
   - Clear UI button ("New Game" or "Play Again")
   - Confirmation prompt if needed ("Start new game? Current progress will be lost.")
   - Works with all input methods

7. Add ending-viewed flag:
   - Set in GameManager when credits complete or are skipped
   - Ensure replay/new game behavior is coherent (e.g., MainMenu shows Continue disabled if starting fresh)
   - Persists through session (but cleared on New Game)
   - Well-documented in comments

8. Add lightweight test hooks or documented developer steps:
   - Debug menu or console commands to set GameManager state and verify all three endings
   - OR documented steps in docs/qa_checklist.md to manually test each ending
   - Clear instructions for QA testers
   - No need to replay full game for testing

9. Add accessibility:
   - Clear visual indicators for ending statistics and credits
   - Skippable credits with any button
   - Text size options (small, normal, large, extra-large)
   - Clear audio/visual feedback for all events
   - Works with all input methods

ACCEPTANCE CRITERIA
- Same saved inputs always result in same ending (deterministic, no randomness)
- Priority rule for Fragile Thaw works correctly (tested with edge cases)
- Credits and New Game do not trap player or leave old consequence state
- All epilogue text and buttons function without errors
- Performance is stable; no lag during credits or transitions
- All inputs work with remapped bindings

DO NOT
- Randomize ending selection or statistics
- Leave old save state after New Game
- Make credits unskippable or overly long
- Create bugs that trap player in epilogue or credits

Finish by reporting:
- Changed files with brief descriptions
- Test results (all three endings tested, New Game tested, save/load verified, accessibility checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 15: epilogue and endings complete
