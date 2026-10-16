extends Node
## QA capture of the expanded Phase 1 (shift rooms, P-2, the second building) in chosen states, from a free camera.
## Not shipped gameplay: it drives the same handlers the player uses (phase1_transfer_controller.gd) and saves PNGs outside
## the repository. Usage (needs a window; Compatibility renderer):
##   godot --path . --resolution 1280x720 res://tools/capture/transfer_capture.tscn -- --shots=<json> --outdir=<dir>
## Shot list: {"shots": [{"name": "...", "do": [step, ...], "cam": [[from], [at]], "fov": 70, "wait_s": 1.2}, ...]}
## Steps (state persists to later shots): ["interact", id] · ["code"] · ["power"] · ["maintenance"] · ["record"] · ["cabinet"] ·
##   ["seam"] · ["door"] (the whole transfer chain, then the door) · ["locale", "en"|"es"] · ["player", x, y, z] ·
##   ["lock"] (open the code lock) · ["keys", "move_up", ...] (events into the lock) · ["detect"] (staff notice her)

const SCENE := "res://scenes/prototypes/phase1_canonical_greybox.tscn"
const CircuitModel := preload("res://scripts/prototypes/phase1_circuit_model.gd")

var _scene: Node3D = null


func _ready() -> void:
	var args := {}
	for raw in OS.get_cmdline_user_args():
		var arg := String(raw).trim_prefix("--")
		var eq := arg.find("=")
		args[arg.substr(0, eq) if eq >= 0 else arg] = arg.substr(eq + 1) if eq >= 0 else "true"
	_run.call_deferred(args)


func _run(args: Dictionary) -> void:
	var spec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(String(args["shots"])))
	var outdir := String(args.get("outdir", "D:/Projects/evidence/final-thaw/transfer"))
	DirAccess.make_dir_recursive_absolute(outdir)
	_scene = (load(SCENE) as PackedScene).instantiate()
	_scene.set("play_intro", false)
	_scene.set("spawn_unit_enabled", bool(spec.get("unit", false)))
	add_child(_scene)
	await get_tree().create_timer(0.6).timeout
	var cam := Camera3D.new()
	_scene.add_child(cam)
	for shot: Dictionary in spec["shots"]:
		for step in shot.get("do", []):
			await _apply(step)
		if shot.has("cam"):
			var c: Array = shot["cam"]
			cam.global_transform = Transform3D(Basis.IDENTITY, Vector3(c[0][0], c[0][1], c[0][2])).looking_at(Vector3(c[1][0], c[1][1], c[1][2]), Vector3.UP)
			cam.fov = float(shot.get("fov", 70.0))
			cam.make_current()
		for layer in _scene.find_children("*", "CanvasLayer", true, false):
			(layer as CanvasLayer).visible = bool(shot.get("hud", false))
		await get_tree().create_timer(float(shot.get("wait_s", 1.4))).timeout
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		var path := "%s/%s.png" % [outdir, String(shot["name"])]
		img.save_png(path)
		print("SHOT ", path)
	get_tree().quit()


func _apply(step: Array) -> void:
	var t = _scene.transfer
	match String(step[0]):
		"interact":
			t.interact(String(step[1]))
		"code":
			t.call("_on_code", "0437")
		"power":
			t.call("_on_code", "0437")
			for id in ["drawer", "substation_door", "terminal", "disconnector"]:
				t.interact(id)
		"maintenance":
			_scene.call("_toggle_maintenance")
		"record":
			_scene.circuit.set_isolated(true)
			_scene.circuit.select_destination(CircuitModel.ARCHIVE)
			_scene.call("_consult_archive")
		"cabinet":
			t.interact("dry_cabinet")
		"seam":
			t.interact("wall_seam")
		"door":
			t.interact("wall_seam")
			t.interact("dry_cabinet")
			t.call("_on_code", "0437")
			for id in ["drawer", "substation_door", "terminal", "disconnector"]:
				t.interact(id)
			_scene.circuit.set_isolated(true)
			_scene.circuit.select_destination(CircuitModel.ARCHIVE)
			_scene.call("_consult_archive")
			t.interact("transfer_door")
		"locale":
			NarrativeTextManager.set_locale(String(step[1]))
		"player":
			_scene.player.global_position = Vector3(float(step[1]), float(step[2]), float(step[3]))
			_scene.player.velocity = Vector3.ZERO
		"lock":
			t.interact("drawer")
		"keys":
			for action in step.slice(1):
				var down := InputEventAction.new()
				down.action = String(action)
				down.pressed = true
				Input.parse_input_event(down)
				await get_tree().physics_frame
				var up := InputEventAction.new()
				up.action = String(action)
				up.pressed = false
				Input.parse_input_event(up)
				await get_tree().physics_frame
		"detect":
			t.call("_noticed")
	await get_tree().create_timer(0.3).timeout
