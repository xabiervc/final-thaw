extends RefCounted
## Mission-level event state for Phase 1 (MISSION1_GHOST_PROTOCOL.md, "Mission-level event contract").
## Separate from the circuit model on purpose: nothing here changes circuit outputs, protection history or saves.
## Session-only: the flags live in memory and are reset with a new mission instance.

## Maintenance OFF -> ON queued the service audit (once; switching maintenance off does not clear it).
var service_override_queued: bool = false
## The restricted record was read with ARCHIVO stable (context only, never a trigger).
var restricted_record_read: bool = false
## The audit crossed G's exterior threshold (exactly once).
var audit_sent: bool = false
## Containment protocol is active (starts together with the audit, exactly once).
var containment_active: bool = false
## Elena crossed the east service mouth into the parking area.
var exit_reached: bool = false


## Call on every maintenance toggle; returns true only on the first OFF -> ON edge.
func on_maintenance(was_on: bool, now_on: bool) -> bool:
	if now_on and not was_on and not service_override_queued:
		service_override_queued = true
		return true
	return false


func on_record_read() -> bool:
	if restricted_record_read:
		return false
	restricted_record_read = true
	return true


## Result of opening G's exterior leaf: "locked" (no queued audit), "containment" (first valid opening) or
## "already" (Containment already running: no duplicate audit, no second alarm, no new unit).
func on_open_g() -> String:
	if audit_sent:
		return "already"
	if not service_override_queued:
		return "locked"
	audit_sent = true
	containment_active = true
	return "containment"


func reset() -> void:
	service_override_queued = false
	restricted_record_read = false
	audit_sent = false
	containment_active = false
	exit_reached = false


func to_dict() -> Dictionary:
	return {
		"SERVICE_OVERRIDE": service_override_queued,
		"RESTRICTED_RECORD_READ": restricted_record_read,
		"AUDIT_SENT": audit_sent,
		"CONTAINMENT": containment_active,
	}
