extends Node

## Single source of truth for which of the two game modes (per the GDD) is
## currently active. Camera mode and phone-panel visibility both derive from
## this instead of tracking their own separate copies of the same fact, and
## a future save system's "current player location" (basement vs.
## investigation stage) and stage manager should read/write this too rather
## than reinventing it.

enum Mode { SANDBOX, QUEST_STAGE }

signal mode_changed(mode: int)

var current: int = Mode.SANDBOX

func set_mode(new_mode: int) -> void:
	if new_mode == current:
		return
	current = new_mode
	mode_changed.emit(current)
