extends Node3D
## World-space affordance for the current interaction target: an amber marker floating above the object and a thin
## ring on the floor around it, so the HUD prompt is visibly tied to one object. Presentation only: it reads
## `manager.current_target` and never changes targeting. Amber is the interactable colour (docs/art/LAB_STYLE_SPEC.md).
## With reduced motion the marker does not bob or spin.

const AMBER := Color(1.0, 0.72, 0.28)
const HOVER := 0.45  # metres above the target's visual top
const BOB_HEIGHT := 0.06
const BOB_SPEED := 3.2
const RING_RADIUS := 0.75

var manager: Node = null

var _marker: MeshInstance3D = null
var _ring: MeshInstance3D = null
var _target: Node3D = null
var _top: float = 1.0
var _t: float = 0.0
var _heights: Dictionary = {}


func _ready() -> void:
	name = "TargetMarker"
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = AMBER
	m.no_depth_test = true
	m.render_priority = 2
	_marker = MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(0.26, 0.22, 0.05)
	_marker.mesh = prism
	_marker.material_override = m
	_marker.rotation_degrees.z = 180.0  # point down at the object
	_marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_marker)
	var rm := StandardMaterial3D.new()
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rm.albedo_color = Color(AMBER, 0.55)
	_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = RING_RADIUS - 0.03
	torus.outer_radius = RING_RADIUS
	torus.rings = 32
	torus.ring_segments = 4
	_ring.mesh = torus
	_ring.material_override = rm
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ring)
	_set_visible(false)


func _set_visible(on: bool) -> void:
	_marker.visible = on
	_ring.visible = on


## Highest point of the target's meshes (cached per target; hidden greybox meshes count, they share the footprint).
func _top_of(target: Node3D) -> float:
	if _heights.has(target):
		return _heights[target]
	var top := target.global_position.y + 1.0
	var found := false
	for m in target.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null:
			continue
		var box := mi.global_transform * mi.get_aabb()
		top = box.end.y if not found else maxf(top, box.end.y)
		found = true
	_heights[target] = top
	return top


func _process(delta: float) -> void:
	_t += delta
	var target: Node3D = null
	if manager != null and is_instance_valid(manager):
		target = manager.get("current_target") as Node3D
	if target == null or not is_instance_valid(target):
		_target = null
		_set_visible(false)
		return
	if target != _target:
		_target = target
		_top = _top_of(target)
	_set_visible(true)
	var reduced := AccessibilityManager.is_reduced_motion()
	var bob := 0.0 if reduced else sin(_t * BOB_SPEED) * BOB_HEIGHT
	var p := target.global_position
	_marker.global_position = Vector3(p.x, _top + HOVER + bob, p.z)
	if not reduced:
		_marker.rotation.y += delta * 1.5
	_ring.global_position = Vector3(p.x, p.y + 0.02, p.z)
