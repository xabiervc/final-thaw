You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect GameManager consequence state and story choices. Phases 0–14 are complete.

**AWARD-LEVEL QUALITY STANDARD**: Endings must be emotionally resonant, cinematically presented, and fully accessible. Target 90+ second cinematics per ending with voice acting, adaptive music, and meaningful closure.

GOAL
Create the epilogue, deterministic ending selection, credits, and a safe New Game loop.

ENDING RULES
Use the saved counters and final evidence choice. Document exact thresholds in code and UI/debug documentation.
- Fragile Thaw has priority if elena_safety <= 1 OR prototype_integrity <= 1.
- Otherwise Public Thaw if civilian_aid >= 4 AND prototype_integrity >= 2 AND evidence_choice == "preserve".
- Otherwise Guarded Thaw.

DELIVERABLES
1. Create scenes/ui/epilogue.tscn with readable story cards or scenes, clearing-weather presentation, and placeholder character/environment art. Design for 90+ second cinematic per ending with smooth camera transitions.
2. Implement one EndingResolver function/resource that applies the rules above. It must be testable and return a named ending key ("public_thaw", "guarded_thaw", "fragile_thaw").
3. Implement narrative content for each ending:
   - **Public Thaw**: Earth recovering, Helix disbanded, Aster open-source. Elena at Iris's grave, Marcus at memorial. Children playing without masks.
   - **Guarded Thaw**: Split screen—protected zones thrive, outside struggles. Resistance forms. Elena disappears working on fix.
   - **Fragile Thaw**: Partial stabilization, communities adapt. Elena injured but determined, Marcus distributing supplies. Recovery takes 40 years.
4. Show clear final statistics: civilians aided, Elena Safety, Prototype Integrity, final evidence decision, memory fragments collected (X/30), nonlethal ratio, and ending title.
5. Create scrolling credits with placeholders for developer names, voice cast, scientific advisors (Dr. Katharine Hayhoe, Dr. Michael Mann), special thanks, and thank-you. Make it skippable after 5s delay. Include adaptive music (piano + strings, ascending for Public Thaw, somber for Guarded, fragile solo piano for Fragile).
6. Add New Game option that calls GameManager.reset_new_game(), clears/replaces save safely, and returns to a new start flow. Confirm with "Are you sure?" prompt.
7. Add an ending-viewed flag and ensure replay/new game behavior is coherent.
8. Add lightweight test hooks or documented developer steps to verify all three endings without replaying full game (e.g., debug menu to force each ending).
9. Add post-credits stinger: Earth from space, 3 years later. Helix logo crumbling. News ticker: "Aster Protocol now open-source. 147 nations deploying." Young scientist opens Aster files: "Let's see what we can do do better." Imply sequel potential.
10. Implement full accessibility for epilogue: subtitles for all narration, speaker labels, high contrast mode support, screen reader compatibility for text.

ACCEPTANCE CRITERIA
- Same saved inputs always result in the same ending.
- Priority rule for Fragile Thaw works.
- Credits and New Game do not trap the player or leave old consequence state.
- All epilogue text and buttons function without errors.
- Cinematics play at 60 FPS with adaptive music.
- Post-credits stinger plays after any ending.
- All accessibility options function in epilogue.

Finish with changed files, test results (verify all 3 endings with debug hooks), known limitations, and propose this commit message exactly:
Phase 15: epilogue, endings, and credits complete with award-level cinematics
