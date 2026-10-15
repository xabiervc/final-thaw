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
##   --scale3d=f             3D resolution scale (HUD stays native)
##   --graphics=performance  graphics preset for this run only (not saved)
##   --tweak=a,b             profiling switches: glow_off, fog_off, adjust_off, ink_off, shadows_off, omni_off, floor_off, pose_off, dressing_off, labels_off, hud_off, elena_off, batches_off, flatmat,
##                           batch_noshadow, flat_std, flat_<shader basename> (e.g. flat_station_surface), hide_<shader basename>,
##                           hrange_<shader>_<lo>_<hi> (batches by number), batch_half, unbatched_off, hn_<node name prefix>
##                           (geometry), lo_<light name prefix>
##   --report                print static batches by material, every light and the unbatched geometry
##   --props=play_intro:false set level properties before it enters the tree
##   --wait=90               frames to wait before the capture
##   --bench=240             frames to measure after the capture (0 = skip)
##   --out=D:/path/shot.png  screenshot output (outside the repository)
##   --shots=res://tools/capture/shots/premium.json --outdir=D:/path   repeatable shot list (one scene load, many
##                           captures; see _run_shots). Before/after comparisons reuse the same list.
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
	if _args.has("graphics"):  # graphics preset for this run only (high | balanced | performance), never saved
		GameManager.settings["graphics"] = _args["graphics"]
	if _args.has("shots"):
		_run_shots.call_deferred()
	else:
		_run.call_deferred()


## Shot list: {"scene": path, "props": {...}, "shots": [shot, ...]}. Each shot (all keys optional except name):
##   "name"            file name (without .png)
##   "calls"           level methods called once before this shot (state persists to later shots)
##   "pos" [x,y,z]     Elena position; "face" [dx,dz] her facing; "yaw"/"pitch" orbit camera; "mode" camera mode
##   "anim" name       Elena animation to hold for the capture ("speed" its playback scale, "seek" a time in s)
##   "unit" [x,y,z]    put the recovery unit here (spawned if needed), facing Elena; "unit_state" display state
##   "cam" [[from],[at]] free camera (overrides the gameplay camera); "fov" its field of view
##   "hud" false       hide every CanvasLayer for this shot
##   "wait_s" seconds  real time to wait before capturing (default 1.2)
##   "scene" path      a different scene for this shot only (e.g. the main menu); "press" button names to press
func _run_shots() -> void:
	var spec_path := String(_args["shots"])
	var spec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(spec_path))
	var outdir := String(_args.get("outdir", "D:/Projects/evidence/final-thaw/shots"))
	DirAccess.make_dir_recursive_absolute(outdir)
	var only := String(_args.get("only", "")).split(",", false)
	var level: Node = null
	var level_scene := String(spec.get("scene", ""))
	var free_cam := Camera3D.new()
	for shot: Dictionary in spec["shots"]:
		var shot_name := String(shot["name"])
		if not only.is_empty() and not (shot_name in only):
			continue
		if shot.has("scene"):
			var other := (load(String(shot["scene"])) as PackedScene).instantiate()
			get_tree().root.add_child(other)
			await _wait_seconds(float(shot.get("wait_s", 1.0)))
			for button_name in shot.get("press", []):
				var button := other.find_child(String(button_name), true, false) as BaseButton
				if button != null:
					button.pressed.emit()
					await _wait_seconds(0.6)
			await RenderingServer.frame_post_draw
			_save(outdir, shot_name)
			other.queue_free()
			await get_tree().process_frame
			continue
		if level == null:
			level = (load(level_scene) as PackedScene).instantiate()
			for key in spec.get("props", {}):
				level.set(key, spec["props"][key])
			get_tree().root.add_child(level)
			await _wait_seconds(0.5)
			level.add_child(free_cam)
		for method in shot.get("calls", []):
			if level.has_method(String(method)):
				level.call(String(method))
				await _wait_seconds(0.25)
		var player = level.get("player")
		if shot.has("pos") and player != null:
			var p: Array = shot["pos"]
			player.global_position = Vector3(p[0], p[1], p[2])
			player.velocity = Vector3.ZERO
		if shot.has("face") and player != null:
			var f: Array = shot["face"]
			player.visual.rotation.y = atan2(float(f[0]), float(f[1]))
		if player != null and shot.has("yaw"):
			player.set("orbit_yaw", float(shot["yaw"]))
		if player != null and shot.has("pitch"):
			player.set("orbit_pitch", float(shot["pitch"]))
		if player != null and shot.has("mode"):
			player.call("set_camera_mode", String(shot["mode"]), true)
		if shot.has("unit"):
			var unit = level.get("unit")
			if unit == null and level.has_method("_spawn_unit"):
				level.call("_spawn_unit")
				unit = level.get("unit")
			if unit != null:
				var u: Array = shot["unit"]
				unit.call("halt")
				unit.global_position = Vector3(u[0], u[1], u[2])
				if player != null:
					var to: Vector3 = player.global_position - unit.global_position
					unit.rotation.y = atan2(to.x, to.z)
				if shot.has("unit_state"):
					unit.set("state", String(shot["unit_state"]))
		for layer in level.find_children("*", "CanvasLayer", true, false):
			layer.visible = bool(shot.get("hud", true))
		if shot.has("cam"):
			var c: Array = shot["cam"]
			var from := Vector3(c[0][0], c[0][1], c[0][2])
			var at := Vector3(c[1][0], c[1][1], c[1][2])
			free_cam.global_transform = Transform3D(Basis.IDENTITY, from).looking_at(at, Vector3.UP)
			free_cam.fov = float(shot.get("fov", 50.0))
			free_cam.make_current()
		elif player != null and player.get("view") != null and not shot.get("keep_camera", false):
			(player.get("view") as Camera3D).make_current()
		var anim: AnimationPlayer = player.get("anim") if player != null else null
		if anim != null and shot.has("anim"):
			player.set("input_enabled", false)
			player.set_physics_process(false)
			anim.play(String(shot["anim"]), 0.0)
			anim.speed_scale = float(shot.get("speed", 1.0))
			if shot.has("seek"):
				anim.seek(float(shot["seek"]), true)
				anim.speed_scale = 0.0
		await _wait_seconds(float(shot.get("wait_s", 1.2)))
		await RenderingServer.frame_post_draw
		_save(outdir, shot_name)
		if player != null:
			player.set_physics_process(true)
	get_tree().quit()


func _wait_seconds(s: float) -> void:
	var end := Time.get_ticks_msec() + int(s * 1000.0)
	while Time.get_ticks_msec() < end:
		await get_tree().process_frame


func _save(outdir: String, shot_name: String) -> void:
	var img := get_viewport().get_texture().get_image()
	var path := outdir.path_join(shot_name + ".png")
	img.save_png(path)
	print("SHOT %s (%dx%d)" % [path, img.get_width(), img.get_height()])


func _run() -> void:
	var scene_path := String(_args.get("scene", "res://scenes/levels/elena_test_room_art.tscn"))
	var t0 := Time.get_ticks_usec()
	var packed := load(scene_path) as PackedScene
	var level := packed.instantiate()
	# --props=name:value,name:value sets level properties before it enters the tree (bool/float/int/string).
	for pair in String(_args.get("props", "")).split(",", false):
		var kv := pair.split(":")
		if kv.size() == 2:
			var v: Variant = kv[1]
			if kv[1] in ["true", "false"]:
				v = kv[1] == "true"
			elif kv[1].is_valid_float():
				v = float(kv[1])
			level.set(kv[0], v)
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
	if _args.has("report"):
		_batch_report(level)
	var bench := int(_args.get("bench", "0"))
	if bench > 0:
		await _bench(bench, load_ms)  # held actions stay pressed, so a held move benchmarks walking
	for action in held:
		Input.action_release(action)
	get_tree().quit()


## Static batches by material and shadow casting (draw-call budget work): count, triangles.
func _batch_report(level: Node) -> void:
	var rows: Dictionary = {}
	for node in level.find_children("StaticBatch_*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var m := mi.material_override
		var key := "%s|%s|shadow=%s" % [m.resource_name if m.resource_name != "" else m.get_class(), (m as ShaderMaterial).shader.resource_path.get_file() if m is ShaderMaterial else "", mi.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF]
		if m is BaseMaterial3D:
			key = "%s|%s|shadow=%s" % [(m as BaseMaterial3D).albedo_color, "std" if (m as BaseMaterial3D).albedo_texture == null else (m as BaseMaterial3D).albedo_texture.resource_path.get_file(), mi.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF]
		var tris := 0
		for sidx in mi.mesh.get_surface_count():
			tris += mi.mesh.surface_get_array_len(sidx) / 3 if mi.mesh.surface_get_array_index_len(sidx) <= 0 else mi.mesh.surface_get_array_index_len(sidx) / 3
		if m is ShaderMaterial and "station" in (m as ShaderMaterial).shader.resource_path:
			var verts := 0
			for sidx in mi.mesh.get_surface_count():
				verts += mi.mesh.surface_get_array_len(sidx)
			print("STATION %s surfaces=%d verts=%d tris=%d aabb=%s layers=%d" % [mi.name, mi.mesh.get_surface_count(), verts, tris, mi.get_aabb().size, mi.layers])
		var row: Array = rows.get(key, [0, 0])
		rows[key] = [row[0] + 1, row[1] + tris]
	var keys := rows.keys()
	keys.sort_custom(func(a, b): return rows[a][0] > rows[b][0])
	var total := 0
	for k in keys:
		total += rows[k][0]
		print("BATCH %4d x  %7d tris  %s" % [rows[k][0], rows[k][1], k])
	print("BATCH TOTAL %d" % total)
	for node in level.find_children("*", "Light3D", true, false):
		var l := node as Light3D
		var rng: float = l.get("omni_range") if l is OmniLight3D else (l.get("spot_range") if l is SpotLight3D else -1.0)
		print("LIGHT %s %s vis=%s shadow=%s energy=%.2f range=%.1f pos=%s mask=%d" % [l.get_class(), l.get_path(), l.is_visible_in_tree(), l.shadow_enabled, l.light_energy, rng, l.global_position.snapped(Vector3.ONE * 0.1), l.light_cull_mask])
	var geo := 0
	for node in level.find_children("*", "GeometryInstance3D", true, false):
		if (node as GeometryInstance3D).is_visible_in_tree() and not str(node.name).begins_with("StaticBatch"):
			geo += 1
			var gi := node as GeometryInstance3D
			var mat: Material = gi.material_override
			if mat == null and gi is MeshInstance3D and (gi as MeshInstance3D).mesh != null and (gi as MeshInstance3D).mesh.get_surface_count() > 0:
				mat = (gi as MeshInstance3D).get_active_material(0)
			var mdesc := "none"
			if mat is ShaderMaterial:
				mdesc = (mat as ShaderMaterial).shader.resource_path.get_file()
			elif mat is BaseMaterial3D:
				mdesc = "std(transp=%d,shading=%d,tex=%s)" % [(mat as BaseMaterial3D).transparency, (mat as BaseMaterial3D).shading_mode, (mat as BaseMaterial3D).albedo_texture != null]
			var size := gi.get_aabb().size * gi.global_transform.basis.get_scale()
			print("GEO %.1f %s %s %s" % [size.length(), gi.get_class(), str(gi.get_path()).replace("/root/Phase1CanonicalGreybox/", ""), mdesc])
	print("UNBATCHED_GEOMETRY %d" % geo)
	# omni lights per geometry instance (Compatibility renderer: every light in range is shaded per pixel, up to the
	# per-object limit), weighted by triangle count is not needed here: the histogram is what matters
	var omnis: Array[OmniLight3D] = []
	for node in level.find_children("*", "OmniLight3D", true, false):
		if (node as OmniLight3D).is_visible_in_tree():
			omnis.append(node)
	var hist: Dictionary = {}
	var worst: Array = []
	for node in level.find_children("*", "GeometryInstance3D", true, false):
		var gi := node as GeometryInstance3D
		if not gi.is_visible_in_tree():
			continue
		var box := gi.global_transform * gi.get_aabb()
		var n := 0
		var names: Array[String] = []
		for l in omnis:
			if (l.light_cull_mask & gi.layers) == 0:
				continue
			var c := l.global_position
			var closest := c.clamp(box.position, box.end)
			if closest.distance_to(c) <= l.omni_range:
				n += 1
				names.append(str(l.name))
		hist[n] = int(hist.get(n, 0)) + 1
		if n >= 6:
			worst.append("%s(%d): %s" % [gi.name, n, ",".join(names)])
	var counts := hist.keys()
	counts.sort()
	for k in counts:
		print("LIGHTS_PER_OBJECT %d -> %d objects" % [k, hist[k]])
	for w in worst.slice(0, 12):
		print("MANY_LIGHTS ", w)


func _bench(frames: int, load_ms: float) -> void:
	var times: Array[float] = []
	var cpu_total := 0.0
	var proc_total := 0.0
	var phys_total := 0.0
	var rcpu_total := 0.0
	var rgpu_total := 0.0
	var vp_rid := get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp_rid, true)
	var last := Time.get_ticks_usec()
	for i in frames:
		await get_tree().process_frame
		rcpu_total += RenderingServer.viewport_get_measured_render_time_cpu(vp_rid) + RenderingServer.get_frame_setup_time_cpu()
		rgpu_total += RenderingServer.viewport_get_measured_render_time_gpu(vp_rid)
		var now := Time.get_ticks_usec()
		times.append(float(now - last) / 1000.0)
		proc_total += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		phys_total += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
		cpu_total = proc_total + phys_total
		last = now
	times.sort()
	var total := 0.0
	for t in times:
		total += t
	var avg := total / times.size()
	var p95 := times[int(times.size() * 0.95)]
	var median := times[times.size() / 2]
	var worst := times[times.size() - 1]
	var spikes := times.filter(func(t): return t > 50.0).size()
	var draws := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var objects := Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var prims := Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	var vram := Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0
	var mem := Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	var nodes := Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	print("BENCH render_cpu_ms=%.2f render_gpu_ms=%.2f" % [rcpu_total / frames, rgpu_total / frames])
	print("BENCH process_ms=%.2f physics_ms=%.2f frames=%d avg_ms=%.2f fps=%.1f median_ms=%.2f p95_ms=%.2f max_ms=%.1f spikes_over_50ms=%d draws=%d objects=%d prims=%d vram_mb=%.1f static_mb=%.1f nodes=%d load_ms=%.0f" % [
		proc_total / frames, phys_total / frames, frames, avg, 1000.0 / avg, median, p95, worst, spikes, draws, objects, prims, vram, mem, nodes, load_ms])


func _apply_tweaks(level: Node) -> void:
	var tweaks := String(_args.get("tweak", "")).split(",", false)
	if "prepass_off" in tweaks or "prepass_on" in tweaks:
		ProjectSettings.set_setting("rendering/driver/depth_prepass/enable", "prepass_on" in tweaks)
	print("DEPTH_PREPASS ", ProjectSettings.get_setting("rendering/driver/depth_prepass/enable"), " vendors_off=", ProjectSettings.get_setting("rendering/driver/depth_prepass/disable_for_vendors"))
	if _args.has("scale3d"):
		get_viewport().scaling_3d_scale = float(_args["scale3d"])
	for node in level.find_children("*", "", true, false):
		if "glow_off" in tweaks and node is WorldEnvironment and node.environment != null:
			node.environment.glow_enabled = false
		if "fog_off" in tweaks and node is WorldEnvironment and node.environment != null:
			node.environment.fog_enabled = false
		if "adjust_off" in tweaks and node is WorldEnvironment and node.environment != null:
			node.environment.adjustment_enabled = false
		if "ink_off" in tweaks and node.name == "InkOutline":
			node.visible = false
		if "shadows_off" in tweaks and node is DirectionalLight3D:
			node.shadow_enabled = false
		if "omni_off" in tweaks and (node is OmniLight3D or node is SpotLight3D):
			node.visible = false
		if "floor_off" in tweaks and node.name == "FacilityFloor":
			node.visible = false
		if "flatmat" in tweaks and node is GeometryInstance3D and not (node is Label3D):
			var flat := StandardMaterial3D.new()
			flat.albedo_color = Color(0.5, 0.5, 0.5)
			(node as GeometryInstance3D).material_override = flat
		if node is MeshInstance3D and str(node.name).begins_with("StaticBatch"):
			var mi := node as MeshInstance3D
			var shader_file := ""
			if mi.material_override is ShaderMaterial:
				shader_file = (mi.material_override as ShaderMaterial).shader.resource_path.get_file().get_basename()
			if ("flat_" + shader_file) in tweaks or ("flat_std" in tweaks and mi.material_override is BaseMaterial3D):
				mi.material_override = _flat_material()
			if ("hide_" + shader_file) in tweaks or ("hide_std" in tweaks and mi.material_override is BaseMaterial3D):
				mi.visible = false
			for t in tweaks:
				if t.begins_with("hrange_"):  # hrange_<shader>_<lo>_<hi>: hide that shader's batches numbered lo..hi-1
					var parts := t.split("_")
					var num := int(str(node.name).get_slice("_", 1))
					if t.trim_prefix("hrange_").begins_with(shader_file) and num >= int(parts[parts.size() - 2]) and num < int(parts[parts.size() - 1]):
						mi.visible = false
			if "batch_half" in tweaks and node.get_index() % 2 == 0:
				mi.visible = false
			if "batch_unshaded" in tweaks:
				var u := StandardMaterial3D.new()
				u.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				u.albedo_color = Color(0.4, 0.4, 0.4)
				mi.material_override = u
			if "batch_vertexlit" in tweaks:
				var v := StandardMaterial3D.new()
				v.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
				v.albedo_color = Color(0.4, 0.4, 0.4)
				mi.material_override = v
			if "batch_nospec" in tweaks:
				var ns := StandardMaterial3D.new()
				ns.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
				ns.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
				ns.albedo_color = Color(0.4, 0.4, 0.4)
				mi.material_override = ns
			if "batch_noshadow" in tweaks:
				mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if node is GeometryInstance3D and not str(node.name).begins_with("StaticBatch") and node.name != "InkOutline":
			if "unbatched_off" in tweaks and not (node.get_parent() is CharacterBody3D or node.find_parent("Elena") != null):
				node.visible = false
			for t in tweaks:
				if t.begins_with("hn_") and str(node.name).begins_with(t.trim_prefix("hn_")):
					node.visible = false
		if node is Light3D:
			for t in tweaks:
				if t.begins_with("lo_") and str(node.name).begins_with(t.trim_prefix("lo_")):
					node.visible = false
				if t.begins_with("orange_") and node is OmniLight3D:  # scale every omni range (lights per object)
					(node as OmniLight3D).omni_range *= float(t.trim_prefix("orange_"))
		if "camera_blank" in tweaks and node is Camera3D:  # 2D, scripts and present only
			(node as Camera3D).cull_mask = 0
		if "labels_off" in tweaks and node is Label3D:
			node.visible = false
		if "hud_off" in tweaks and node is CanvasLayer:
			node.visible = false
		if "elena_off" in tweaks and node is CharacterBody3D and node.name == "Elena":
			(node.get("visual") as Node3D).visible = false
		if "batches_off" in tweaks and node is MeshInstance3D and str(node.name).begins_with("StaticBatch"):
			node.visible = false
		for b in 4:
			if ("band%d_off" % b) in tweaks and node is VisualInstance3D and (node as VisualInstance3D).layers == (1 << (b + 1)):
				node.visible = false
		if "pose_off" in tweaks and node.name == "ProceduralPose":
			node.process_mode = Node.PROCESS_MODE_DISABLED
		if "dressing_off" in tweaks and node is GeometryInstance3D and node.get_parent() != null and node.get_parent().name == "TestRoomDressing":
			node.visible = false
	if not tweaks.is_empty():
		print("TWEAKS ", tweaks)


var _flat: StandardMaterial3D


func _flat_material() -> StandardMaterial3D:
	if _flat == null:
		_flat = StandardMaterial3D.new()
		_flat.albedo_color = Color(0.5, 0.5, 0.5)
	return _flat


func _find_room(level: Node) -> Node:
	if level.get("elena") != null:
		return level
	for child in level.find_children("*", "Node3D", true, false):
		if child.get("elena") != null:
			return child
	return null
