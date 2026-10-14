extends Node
## In-game capture and benchmark harness (QA tool, not shipped gameplay).
##
## Loads a level scene with the real autoloads, optionally places Elena, drives interactions, waits, then saves a
## viewport screenshot and prints frame-time / render statistics. Arguments come after `--`:
##   --scene=res://scenes/levels/elena_test_room_art.tscn
##   --pos=x,y,z             teleport Elena (the camera snaps to her)
##   --face=x,z              face direction for Elena's model
##   --actions=a,b,c         call interact() on level properties in order (terminal, door_a, lever, door)
##   --scan                  trigger a scan before capturing
##   --overview=h,d          review framing of the whole room: camera offset (0, h, d), no limits
##   --hold=a,b              hold these input actions (e.g. move_right,jump) during the wait
##   --yaw=r --pitch=r       orbit camera angles (radians) for scenes with an orbit player (Phase 1)
##   --call=m1,m2            call these methods on the level root, in order (state setup, e.g. _toggle_maintenance)
##   --tweak=a,b             profiling switches: glow_off, shadows_off, omni_off, floor_off, pose_off, dressing_off
##   --wait=90               frames to wait before the capture
##   --bench=240             frames to measure after the capture (0 = skip)
##   --out=D:/path/shot.png  screenshot output (outside the repository)
## Example:
##   godot --path . --resolution 1920x1080 res://tools/capture/scene_capture.tscn -- --pos=-9.5,0.1,3.5 --out=D:/Projects/evidence/a.png

var _args: Dictionary = {}


func _ready() -> void:
	for raw in OS.get_cmdline_user_args():
		var arg := String(raw).trim_prefix("--")
		var eq := arg.find("=")
		if eq < 0:
			_args[arg] = "true"
		else:
			_args[arg.substr(0, eq)] = arg.substr(eq + 1)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	_run.call_deferred()


func _run() -> void:
	var scene_path := String(_args.get("scene", "res://scenes/levels/elena_test_room_art.tscn"))
	var t0 := Time.get_ticks_usec()
	var packed := load(scene_path) as PackedScene
	var level := packed.instantiate()
	get_tree().root.add_child(level)
	await get_tree().process_frame
	await get_tree().process_frame
	var load_ms := float(Time.get_ticks_usec() - t0) / 1000.0
	_apply_tweaks(level)
	for method in String(_args.get("call", "")).split(",", false):
		if level.has_method(method):
			level.call(method)
			await get_tree().create_timer(0.2).timeout
	var orbit = level.get("player")
	if orbit != null and orbit.get("orbit_yaw") != null:
		if _args.has("pos"):
			var op := String(_args["pos"]).split_floats(",")
			orbit.global_position = Vector3(op[0], op[1], op[2])
		if _args.has("yaw"):
			orbit.set("orbit_yaw", float(_args["yaw"]))
		if _args.has("pitch"):
			orbit.set("orbit_pitch", float(_args["pitch"]))
	var room := _find_room(level)
	if room != null:
		var elena = room.get("elena")
		if _args.has("pos") and elena != null:
			var p := String(_args["pos"]).split_floats(",")
			elena.global_position = Vector3(p[0], p[1], p[2])
			for cam in level.find_children("*", "Camera3D", true, false):
				if cam.has_method("_desired"):
					cam.global_position = cam.call("_desired")
		if _args.has("face") and elena != null:
			var f := String(_args["face"]).split_floats(",")
			elena.visual.rotation.y = atan2(f[0], f[1])
		if _args.has("overview"):
			# Review-only framing of the whole room: same pitch family as the game camera, much further out.
			for cam in level.find_children("*", "Camera3D", true, false):
				if cam.get("offset") != null:
					var o := String(_args["overview"]).split_floats(",")
					cam.set("offset", Vector3(0.0, o[0], o[1]))
					cam.set("limit_min", Vector2(-1000, -1000))
					cam.set("limit_max", Vector2(1000, 1000))
					cam.rotation = Vector3(-atan2(o[0], o[1]), 0.0, 0.0)
					cam.fov = 50.0
					cam.global_position = cam.call("_desired")
		for action in String(_args.get("actions", "")).split(",", false):
			var target = room.get(action)
			if target != null:
				target.call("interact", elena)
				await get_tree().create_timer(0.1).timeout
	var held := String(_args.get("hold", "")).split(",", false)
	for action in held:
		Input.action_press(action)
	var wait := int(_args.get("wait", "90"))
	for i in wait:
		await get_tree().process_frame
	if _args.has("scan") and room != null and room.get("scanner") != null:
		room.get("scanner").call("scan")
		for i in 20:
			await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var out := String(_args.get("out", ""))
	if out != "":
		var img := get_viewport().get_texture().get_image()
		img.save_png(out)
		print("CAPTURE saved %s (%dx%d)" % [out, img.get_width(), img.get_height()])
	var bench := int(_args.get("bench", "0"))
	if bench > 0:
		await _bench(bench, load_ms)  # held actions stay pressed, so a held move benchmarks walking
	for action in held:
		Input.action_release(action)
	get_tree().quit()


func _bench(frames: int, load_ms: float) -> void:
	var times: Array[float] = []
	var cpu_total := 0.0
	var last := Time.get_ticks_usec()
	for i in frames:
		await get_tree().process_frame
		var now := Time.get_ticks_usec()
		times.append(float(now - last) / 1000.0)
		cpu_total += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0 + Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
		last = now
	times.sort()
	var total := 0.0
	for t in times:
		total += t
	var avg := total / times.size()
	var p95 := times[int(times.size() * 0.95)]
	var draws := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var objects := Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var prims := Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	var vram := Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0
	var mem := Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	var nodes := Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	print("BENCH cpu_ms=%.2f frames=%d avg_ms=%.2f fps=%.1f p95_ms=%.2f draws=%d objects=%d prims=%d vram_mb=%.1f static_mb=%.1f nodes=%d load_ms=%.0f" % [
		cpu_total / frames, frames, avg, 1000.0 / avg, p95, draws, objects, prims, vram, mem, nodes, load_ms])


func _apply_tweaks(level: Node) -> void:
	var tweaks := String(_args.get("tweak", "")).split(",", false)
	for node in level.find_children("*", "", true, false):
		if "glow_off" in tweaks and node is WorldEnvironment and node.environment != null:
			node.environment.glow_enabled = false
		if "shadows_off" in tweaks and node is DirectionalLight3D:
			node.shadow_enabled = false
		if "omni_off" in tweaks and node is OmniLight3D:
			node.visible = false
		if "floor_off" in tweaks and node.name == "FacilityFloor":
			node.visible = false
		if "pose_off" in tweaks and node.name == "ProceduralPose":
			node.process_mode = Node.PROCESS_MODE_DISABLED
		if "dressing_off" in tweaks and node is GeometryInstance3D and node.get_parent() != null and node.get_parent().name == "TestRoomDressing":
			node.visible = false
	if not tweaks.is_empty():
		print("TWEAKS ", tweaks)


func _find_room(level: Node) -> Node:
	if level.get("elena") != null:
		return level
	for child in level.find_children("*", "Node3D", true, false):
		if child.get("elena") != null:
			return child
	return null
