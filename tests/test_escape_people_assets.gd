extends Node

const PersonVisualScript := preload("res://scripts/characters/person_visual.gd")
const ACTORS := {
	"T1": "helix_tech_a",
	"T2": "helix_tech_b",
	"T3": "helix_supervisor",
	"G1": "helix_guard_a",
	"G2": "helix_guard_b",
}

var passed := 0
var failed := 0


func _ready() -> void:
	for actor_id in ACTORS:
		var person = PersonVisualScript.new()
		person.person = ACTORS[actor_id]
		person.name = actor_id
		add_child(person)
		await get_tree().process_frame
		_expect(person.model != null, "%s model loads" % actor_id)
		_expect(person.anim != null, "%s has an AnimationPlayer" % actor_id)
		_expect(person.anim != null and person.anim.has_animation("idle") and person.anim.has_animation("run"), "%s supports idle and pursuit locomotion" % actor_id)
		_expect(person.height > 1.4 and person.height < 1.9, "%s roster height is in metres" % actor_id)
	print("Escape people assets: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(ok: bool, label: String) -> void:
	if ok:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
