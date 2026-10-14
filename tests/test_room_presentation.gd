extends Node
## Presentation layer of the dressed Elena test room: power rig, sound layer, HUD prompt/banners, target marker,
## and Elena's procedural pose. Run: godot --headless --path . res://tests/test_room_presentation.tscn

const ART_SCENE := "res://scenes/levels/elena_test_room_art.tscn"
const Synth := preload("res://scripts/audio/sfx_synth.gd")
const HudScript := preload("res://scripts/ui/prompt_hud.gd")

var failed := 0
var passed := 0
var _reached_end := false  # a script error aborts the coroutine; this turns that into a failure


func _ready() -> void:
	_test_synth()
	await _test_room()
	_expect(_reached_end, "END: every room check ran to completion")
	print("Room presentation: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _peak(stream: AudioStreamWAV) -> int:
	var data := stream.data
	var m := 0
	for i in range(0, data.size(), 2):
		m = maxi(m, absi(data.decode_s16(i)))
	return m


func _test_synth() -> void:
	var hum := Synth.generator_hum()
	_expect(hum.loop_mode == AudioStreamWAV.LOOP_FORWARD and hum.loop_end > 0, "S1: the generator hum loops")
	_expect(_peak(hum) > 1000, "S2: the generator hum is not silent")
	var a := Synth.footstep(1)
	var b := Synth.footstep(1)
	_expect(a.data == b.data, "S3: synthesis is deterministic (same variant -> identical samples)")
	_expect(Synth.footstep(0).data != Synth.footstep(2).data, "S4: footstep variants differ")
	_expect(Synth.terminal_beep().loop_mode == AudioStreamWAV.LOOP_DISABLED, "S5: one-shots do not loop")


func _test_room() -> void:
	var art := (load(ART_SCENE) as PackedScene).instantiate()
	add_child(art)
	await get_tree().process_frame
	await get_tree().process_frame
	var room: Node = null
	for n in art.find_children("*", "Node3D", true, false):
		if n.get("elena") != null:
			room = n
	_expect(room != null, "P0: the art wrapper instances the room")
	var dressing := art.get_node_or_null("TestRoomDressing")
	_expect(dressing != null, "P1: the test-room dressing is present")
	var reskinned := 0
	for body in room.get_children():
		if body is StaticBody3D and body.get_script() == null:
			for m in body.get_children():
				if m is MeshInstance3D and (m as MeshInstance3D).material_override is ShaderMaterial:
					reskinned += 1
	_expect(reskinned >= 10, "P2: greybox walls are re-skinned with facility materials (%d)" % reskinned)

	var power = dressing.get("power")
	var audio = dressing.get("audio")
	var hud = room.get("hud")
	var lever = room.get("lever")
	var circuit_on := func() -> float:
		var total := 0.0
		for l in power.find_children("Power*", "OmniLight3D", true, false):
			total += (l as OmniLight3D).light_energy
		return total
	_expect(not power.powered and circuit_on.call() == 0.0, "P3: before the lever the generator circuit is dark")
	_expect(not audio.is_generator_running() and audio.get_node("GeneratorAlarm").playing, "P4: unpowered: alarm pip on, hum off")

	# Keycap shows the live binding of `interact`, also after remapping it.
	hud.set_prompt("[E] Accionar palanca - Palanca del generador")
	_expect(hud._prompt_verb.text == "Accionar palanca" and hud._prompt_name.text == "Palanca del generador", "P5: the prompt line is split into verb and object")
	var saved := InputMap.action_get_events("interact")
	InputMap.action_erase_events("interact")
	var g := InputEventKey.new()
	g.physical_keycode = KEY_G
	InputMap.action_add_event("interact", g)
	hud.set_prompt("")
	hud.set_prompt("[E] Accionar palanca - Palanca del generador")
	_expect(hud._prompt_key.text == "G", "P6: after remapping interact to G the key cap shows G")
	_expect(HudScript.control_legend().contains("G "), "P7: the control legend follows the remapped key")
	InputMap.action_erase_events("interact")
	for e in saved:
		InputMap.action_add_event("interact", e)

	lever.interact(room.get("elena"))
	await _wait(2.5)
	_expect(power.powered and circuit_on.call() > 3.0, "P8: pulling the lever brings the generator circuit online")
	var status := power.mats.get_material("status_power") as StandardMaterial3D
	_expect(status.emission.g > status.emission.r, "P9: status strips turn green with power")
	_expect(audio.is_generator_running() and not audio.get_node("GeneratorAlarm").playing, "P10: powered: hum on, alarm off")
	_expect(hud.is_banner_visible(), "P11: a banner announces the power change")

	# Loading a save replays lever state without re-announcing it.
	await _wait(5.0)
	room.set("_loading", true)
	lever.apply_state({"on": false})
	lever.apply_state({"on": true})
	room.set("_loading", false)
	_expect(not hud.is_banner_visible(), "P12: restoring lever state from a save shows no banner")

	# Target marker follows the interaction target.
	var marker := room.get_node_or_null("TargetMarker")
	var elena = room.get("elena")
	elena.global_position = Vector3(-10.5, 0.1, -1.8)  # in front of the security terminal
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var target = room.get("manager").get("current_target")
	_expect(target == room.get("terminal"), "P13: standing at the terminal targets it")
	_expect(marker != null and marker.get("_marker").visible, "P14: the target marker is shown over the current target")
	elena.global_position = Vector3(-2.0, 0.1, 5.5)  # open floor, nothing in range
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(not marker.get("_marker").visible, "P15: with no target the marker hides")

	# The alcove wall is cut away while Elena stands behind it, and restored when she leaves.
	var fade = dressing.get("alcove_fade")
	var wall_mat := dressing.get("mats").get_material("wall_alcove") as ShaderMaterial
	elena.global_position = Vector3(5.0, 0.1, -5.4)
	await _wait(0.6)
	elena.global_position = Vector3(5.0, 0.1, -5.4)
	await get_tree().process_frame
	_expect(fade.is_faded() and float(wall_mat.get_shader_parameter("dither_fade")) > 0.5, "P18: inside the alcove the wall hiding Elena is cut away")
	elena.global_position = Vector3(5.5, 0.1, -1.0)
	await _wait(0.6)
	_expect(not fade.is_faded() and float(wall_mat.get_shader_parameter("dither_fade")) == 0.0, "P19: outside the alcove the wall is solid again")
	var other_wall := dressing.get("mats").get_material("wall") as ShaderMaterial
	var other_fade = other_wall.get_shader_parameter("dither_fade")
	_expect(other_fade == null or float(other_fade) == 0.0, "P20: the cutaway never affects the other walls")

	# Procedural pose lowers the bind-pose arms.
	var pose = elena.get("pose")
	if elena.get("uses_mpfb_model"):
		_expect(pose != null and pose.ready_ok, "P16: the procedural pose layer is set up on the MPFB rig")
		var sk: Skeleton3D = pose.skeleton
		# Skeleton space is not Y-up on this rig; compare the upper-arm direction with the rig's own down axis.
		var up: Vector3 = pose.get("_up")
		var shoulder := sk.find_bone("upperarm_l")
		var elbow := sk.find_bone("lowerarm_l")
		var rest_dir := (sk.get_bone_global_rest(elbow).origin - sk.get_bone_global_rest(shoulder).origin).normalized()
		var posed_dir := (sk.get_bone_global_pose(elbow).origin - sk.get_bone_global_pose(shoulder).origin).normalized()
		var rest_down := rad_to_deg(rest_dir.angle_to(-up))
		var posed_down := rad_to_deg(posed_dir.angle_to(-up))
		_expect(posed_down < 20.0 and rest_down > posed_down + 15.0, "P17: the upper arm hangs down (%.0f deg from vertical, bind pose %.0f deg)" % [posed_down, rest_down])
	_reached_end = true
	art.queue_free()
	await get_tree().process_frame
