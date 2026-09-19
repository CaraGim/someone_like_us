extends Node

## Shared source of truth for "is the player currently free to interact with
## the world right now". Any UI system (phone, crafting, dialogue, minigame
## overlays, ...) calls lock()/unlock() instead of Player accumulating a
## separate bool per system. Ref-counted so overlapping locks (e.g. a
## cutscene starting while the phone is open) don't unlock prematurely.

signal lock_state_changed(is_locked: bool)

var _lock_count: int = 0

func lock() -> void:
	_lock_count += 1
	if _lock_count == 1:
		lock_state_changed.emit(true)

func unlock() -> void:
	_lock_count = maxi(_lock_count - 1, 0)
	if _lock_count == 0:
		lock_state_changed.emit(false)

func is_locked() -> bool:
	return _lock_count > 0
