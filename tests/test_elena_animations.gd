extends Node
## Elena's animations (v2: CMU motion-capture locomotion and the v1 procedural gestures, tools/blender/elena_mpfb/animate_elena_v2.py)
## are present with the exact names, loop where they should, have sensible lengths, do not move the character horizontally and
## animate the same skeleton the model uses.
## Ejecutar: godot --headless --path . res://tests/test_elena_animations.tscn
## Codigo de salida: 0 si todo pasa, 1 si algo falla.

const MODEL := "res://assets/models/characters/elena/elena.glb"
const NAMES := ["idle", "walk", "run", "sprint", "crouch_idle", "crouch_walk", "jump", "fall", "land", "climb", "scan", "interact", "alert", "caught"]
const LOOPING := ["idle", "walk", "run", "sprint", "crouch_idle", "crouch_walk", "fall"]
const MIN_LENGTH := 0.3
const MAX_LENGTH := 4.0
const MAX_HORIZONTAL_TRAVEL := 0.03  # metres of pelvis drift allowed (it is only the grounding correction)
## Standing clips keep the captured weight shifts: the hips may sway this much, but the feet are pinned (checked below).
## `scan` is standing capture too (77_02 with the wrist-reading arm layer, feet pinned).
const IDLE_CLIPS := ["idle", "crouch_idle", "scan"]
const MAX_IDLE_SWAY := 0.06
const MAX_PLANTED_FOOT_SLIDE := 0.02

var failed := 0
var passed := 0


func _ready() -> void:
	var model := (load(MODEL) as PackedScene).instantiate()
	add_child(model)
	await get_tree().process_frame
	var players := model.find_children("*", "AnimationPlayer", true, false)
	_expect(players.size() == 1, "the model has one AnimationPlayer")
	var skeletons := model.find_children("*", "Skeleton3D", true, false)
	_expect(skeletons.size() == 1, "the model has one Skeleton3D")
	var player := players[0] as AnimationPlayer
	var skeleton := skeletons[0] as Skeleton3D
	_expect(skeleton.get_bone_count() >= 53, "the skeleton keeps its bones (%d)" % skeleton.get_bone_count())
	for animation_name in NAMES:
		_expect(player.has_animation(animation_name), "animation '%s' exists" % animation_name)
		if not player.has_animation(animation_name):
			continue
		var animation := player.get_animation(animation_name)
		_expect(animation.length >= MIN_LENGTH and animation.length <= MAX_LENGTH, "'%s' length is sensible (%.2f s)" % [animation_name, animation.length])
		var should_loop := LOOPING.has(animation_name)
		_expect((animation.loop_mode == Animation.LOOP_LINEAR) == should_loop, "'%s' loop mode matches (%s)" % [animation_name, "loop" if should_loop else "once"])
		var bones_ok := true
		var travel := 0.0
		for track in animation.get_track_count():
			var path := String(animation.track_get_path(track))
			var bone := path.get_slice(":", 1)
			if skeleton.find_bone(bone) < 0:
				bones_ok = false
			if bone == "pelvis" and animation.track_get_type(track) == Animation.TYPE_POSITION_3D:
				var first: Vector3 = animation.track_get_key_value(track, 0)
				for key in animation.track_get_key_count(track):
					var value: Vector3 = animation.track_get_key_value(track, key)
					travel = maxf(travel, Vector2(value.x - first.x, value.y - first.y).length())  # x,y of the parent frame are horizontal
		_expect(bones_ok, "'%s' only animates bones that exist" % animation_name)
		var limit := MAX_IDLE_SWAY if IDLE_CLIPS.has(animation_name) else MAX_HORIZONTAL_TRAVEL
		_expect(travel <= limit, "'%s' does not move the character horizontally (%.3f m, limit %.2f)" % [animation_name, travel, limit])
		if should_loop:
			var closed := true
			for track in animation.get_track_count():
				var last := animation.track_get_key_count(track) - 1
				if animation.track_get_type(track) == Animation.TYPE_ROTATION_3D:
					var a: Quaternion = animation.track_get_key_value(track, 0)
					var b: Quaternion = animation.track_get_key_value(track, last)
					if absf(a.dot(b)) < 0.9995:
						closed = false
			_expect(closed, "'%s' closes its loop (first key = last key)" % animation_name)
	# standing clips: the feet stay planted while the hips shift
	for clip in IDLE_CLIPS:
		if not player.has_animation(clip):
			continue
		player.play(clip)
		var length := player.get_animation(clip).length
		var first := {}
		var slide := 0.0
		for i in 12:
			player.seek(length * float(i) / 12.0, true)
			await get_tree().process_frame
			for foot in ["foot_l", "foot_r"]:
				var p := skeleton.get_bone_global_pose(skeleton.find_bone(foot)).origin
				if not first.has(foot):
					first[foot] = p
				slide = maxf(slide, Vector2(p.x - first[foot].x, p.z - first[foot].z).length())
		_expect(slide <= MAX_PLANTED_FOOT_SLIDE, "'%s' keeps both feet planted (max slide %.3f m)" % [clip, slide])
	# the pose really changes the skeleton
	player.play("crouch_idle")
	player.seek(0.5, true)
	await get_tree().process_frame
	var head := skeleton.get_bone_global_pose(skeleton.find_bone("head")).origin
	_expect(head.y < 1.3, "crouch_idle lowers the head (y = %.2f m)" % head.y)
	print("Elena animations: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(cond: bool, message: String) -> void:
	if cond:
		passed += 1
		print("PASS: ", message)
	else:
		failed += 1
		push_error("FAIL: " + message)
