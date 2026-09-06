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

