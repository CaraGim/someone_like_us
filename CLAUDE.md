# CLAUDE.md — Someone Like Us (Godot 4 prototype)



## Project context

This is a pre-production vertical-slice prototype.

The goal right now is correct game logic and structure, not final presentation. Graphics, UI art, and audio assets are not ready and will be added later, one system at a time.

Reference specs live in 'docs/gdd/' — check there for mechanic details(Game\_Mechanism.txt, quest\_scenario.txt, UI\_scenario.txt, Aduio\_list.txt, Game\_Data.txt) before implementing a system, rather than guessing behavior.





## Asset stub rules

* **UI:** no art yet — build with simple primitive shapes (colored rectangles, plain buttons) that are functionally complete but visually bare.
* **SFX:** no sound files yet — generate a short procedural beep as a placeholder for any missing sound effect.
* **BGM:** no placeholder — leave silence where background music is specified. Do not generate substitute music.





## Priority

Build real, working logic first. Presentation-layer stubs exist only so the structure is testable — they are expected to be replaced later, not polished.



## Known gotcha: hidden non-breaking spaces in docs/gdd/*.txt

The `.txt` files in `docs/gdd/` (likely pasted from Word/Notion/similar rich-text editors) contain hidden **non-breaking space characters (U+00A0)** mixed in among normal spaces (U+0020) — visually identical but byte-different.

**Symptom:** An exact-match text edit (e.g. Edit tool's old_string/new_string) fails with "string not found," even when the target text was just read from the same file and looks identical.

**Fix:** Don't assume a copy-pasted match will work. If an edit unexpectedly fails to match on these files, dump the character codes of the line in question (e.g. via PowerShell: `[int][char]` per character) to check for `160` (U+00A0) where a normal space (`32`) is expected, then perform the replacement using the actual `[char]0x00A0` character (or operate on the file directly, e.g. via a PowerShell script) instead of retyping the text.

