class_name PersonVisual
extends Node3D
## A Phase 2 person: Helix annex staff or a street civilian (assets/models/characters/people/, built by
## tools/blender/people_mpfb/build_people.py from MPFB 2 humans with MakeHuman CC0 assets and CMU motion capture).
##
## Loads the model, gives it the illustrated materials (docs/art/ASSET_PRODUCTION_BIBLE.md, "Illustrated style"), sets
## the loop flags from people_clips.json and plays clips with the cycle matched to the body's ground speed, so the feet
## do not skate. The model faces +Z, like Elena's: turn this node with rotation.y = atan2(dir.x, dir.z).

const DIR := "res://assets/models/characters/people/"
const CLIPS_PATH := DIR + "people_clips.json"
const FacilityMaterials := preload("res://scripts/levels/test_room_art/facility_materials.gd")
## Parts drawn with alpha (MakeHuman strands and lashes) and parts that keep a specular highlight (characters only).
const ALPHA_PARTS := ["hair", "brows", "lashes"]
const SPECULAR_PARTS := ["skin", "eyes"]
const BLEND := 0.22
const SPEED_SCALE_RANGE := Vector2(0.55, 1.8)

static var _table: Dictionary = {}

@export var person: String = "helix_guard_a"
var model: Node3D = null
var anim: AnimationPlayer = null
var clips: Dictionary = {}
var current: String = ""
var height: float = 1.75


static func table() -> Dictionary:
	if _table.is_empty() and FileAccess.file_exists(CLIPS_PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(CLIPS_PATH))
		if parsed is Dictionary:
			_table = parsed
	return _table


static func exists(person_id: String) -> bool:
	return ResourceLoader.exists(DIR + person_id + ".glb")


func _ready() -> void:
	if model == null:
		load_model()


## Instances the model. Returns false (and stays empty) if the GLB is missing or not imported.
func load_model() -> bool:
	var path := DIR + person + ".glb"
	if not ResourceLoader.exists(path):
		push_warning("PersonVisual: no model for '%s'" % person)
		return false
	var scene := load(path) as PackedScene
	if scene == null:
		return false
	model = scene.instantiate() as Node3D
	model.name = "Model"
	add_child(model)
	_dress(model)
	var players := model.find_children("*", "AnimationPlayer", true, false)
	if not players.is_empty():
		anim = players[0] as AnimationPlayer
	var entry: Dictionary = table().get(person, {})
	clips = entry.get("clips", {})
	height = float(entry.get("height", 1.75))
	if anim != null:
		for clip_name in clips:
			if anim.has_animation(clip_name):
				anim.get_animation(clip_name).loop_mode = Animation.LOOP_LINEAR if bool(clips[clip_name].get("loop", false)) else Animation.LOOP_NONE
		play("idle")
	return true


## Plays a clip (crossfaded). For travelling cycles, `ground_speed` (m/s) sets the playback rate from the clip's natural
## speed; other clips play at `rate`.
func play(clip: String, ground_speed: float = -1.0, rate: float = 1.0) -> void:
	if anim == null or not anim.has_animation(clip):
		return
	var natural := float(clips.get(clip, {}).get("speed", 0.0))
	var scale := rate
	if natural > 0.05 and ground_speed > 0.0:
		scale = clampf(ground_speed / natural, SPEED_SCALE_RANGE.x, SPEED_SCALE_RANGE.y)
	anim.speed_scale = scale
	if clip != current or not anim.is_playing():
		anim.play(clip, BLEND)
		current = clip


func clip_length(clip: String) -> float:
	return anim.get_animation(clip).length if anim != null and anim.has_animation(clip) else 0.0


## Turns toward a horizontal direction at `rate` rad/s (instant when rate <= 0).
func face(dir: Vector3, delta: float = 0.0, rate: float = 0.0) -> void:
	if Vector2(dir.x, dir.z).length() < 0.001:
		return
	var wanted := atan2(dir.x, dir.z)
	rotation.y = wanted if rate <= 0.0 else lerp_angle(rotation.y, wanted, clampf(rate * delta, 0.0, 1.0))


func forward() -> Vector3:
	return Vector3(sin(rotation.y), 0.0, cos(rotation.y))


func _dress(root: Node) -> void:
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		if mi.mesh == null:
			continue
		for surface in mi.mesh.get_surface_count():
			var imported := mi.mesh.surface_get_material(surface) as BaseMaterial3D
			if imported == null:
				continue
			var m := imported.duplicate() as BaseMaterial3D
			var part := String(imported.resource_name).trim_prefix(person + "_")
			m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
			m.specular_mode = BaseMaterial3D.SPECULAR_TOON if part in SPECULAR_PARTS else BaseMaterial3D.SPECULAR_DISABLED
			m.roughness = 0.7 if part == "skin" else 0.85
			m.metallic = 0.0
			if part in ALPHA_PARTS:
				m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				m.alpha_scissor_threshold = 0.45
				m.cull_mode = BaseMaterial3D.CULL_DISABLED
			else:
				m.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			mi.set_surface_override_material(surface, m)
