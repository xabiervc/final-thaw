You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect GameManager consequence state and story choices. Phases 0–14 are complete.

GOAL
Create the epilogue, deterministic ending selection, credits, and a safe New Game loop.

ENDING RULES
Use the saved counters and final evidence choice. Document exact thresholds in code and UI/debug documentation.
- Fragile Thaw has priority if elena_safety <= 1 OR prototype_integrity <= 1.
- Otherwise Public Thaw if civilian_aid >= 4 AND prototype_integrity >= 2 AND evidence_choice == "preserve".
- Otherwise Guarded Thaw.

DELIVERABLES
1. Create scenes/ui/epilogue.tscn with readable story cards or scenes, clearing-weather presentation, and placeholder character/environment art.
2. Implement one EndingResolver function/resource that applies the rules above. It must be testable and return a named ending key.
3. Implement concise narrative content for Public Thaw, Guarded Thaw, and Fragile Thaw.
4. Show clear final statistics: civilians aided, Elena Safety, Prototype Integrity, final evidence decision, and ending title.
5. Create scrolling credits with placeholders for developer names and a thank-you. Make it skippable after a short delay.
6. Add New Game option that calls GameManager.reset_new_game(), clears/replaces save safely, and returns to a new start flow.
7. Add an ending-viewed flag and ensure replay/new game behavior is coherent.
8. Add lightweight test hooks or documented developer steps to verify all three endings without replaying full game.

ACCEPTANCE CRITERIA
- Same saved inputs always result in the same ending.
- Priority rule for Fragile Thaw works.
- Credits and New Game do not trap the player or leave old consequence state.
- All epilogue text and buttons function without errors.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 15: epilogue and endings complete
