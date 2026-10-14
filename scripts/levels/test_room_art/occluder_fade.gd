extends Node
## Cuts away a wall while the player stands in the region it hides from the camera.
## Used for the generator alcove: the wall that hides the lever from view would otherwise hide Elena too.
## The wall dithers out through its shader (`dither_fade`, opaque pipeline: GeometryInstance3D.transparency has no
## effect on the Compatibility renderer); small parts mounted on it are hidden while it is cut away.
## Visual only; collision is untouched. With reduced motion the change is instant.

const FADED := 0.8
const FADE_SPEED := 4.0
const HIDE_PARTS_ABOVE := 0.3

var target: Node3D = null
## Hidden region on the floor plane: Rect2(x, z, width, depth).
var region: Rect2 = Rect2()
var wall_material: ShaderMaterial = null
var parts: Array = []  # Node3D mounted on the wall

var _amount: float = 0.0


func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	var p := target.global_position
	var goal := FADED if region.has_point(Vector2(p.x, p.z)) else 0.0
	if AccessibilityManager.is_reduced_motion():
		_amount = goal
	else:
		_amount = move_toward(_amount, goal, delta * FADE_SPEED)
	if wall_material != null:
		wall_material.set_shader_parameter("dither_fade", _amount)
	var show_parts := _amount <= HIDE_PARTS_ABOVE
	for part in parts:
		if is_instance_valid(part):
			(part as Node3D).visible = show_parts


func is_faded() -> bool:
	return _amount > 0.5
