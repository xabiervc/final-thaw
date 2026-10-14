extends RefCounted
## Phase 1 -> Phase 2 handoff (session memory only).
## A static dictionary survives the scene change, is consumed exactly once by the parking scene, and is never written
## to the save file or to an autoload. Without a pending handoff the parking scene keeps its standalone start.

static var _pending: Dictionary = {}


static func store(state: Dictionary) -> void:
	_pending = state.duplicate(true)


static func has_pending() -> bool:
	return not _pending.is_empty()


## Returns the pending state and clears it, so a later standalone run never inherits stale data.
static func consume() -> Dictionary:
	var out := _pending
	_pending = {}
	return out


static func peek() -> Dictionary:
	return _pending
