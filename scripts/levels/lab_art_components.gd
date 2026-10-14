extends Node
## Visual-only art for the interactive components (decision D1, docs/art/LAB_KIT_PLAN.md).
##
## For each known component script found under the host level, this hangs the Batch 2 art GLB under the component node
## (so it inherits the component's position/rotation and the scan highlight, which walks the component's mesh children),
## hides the component's greybox meshes (render layer 0), and every frame copies the greybox glow state onto the art's emissive parts.
## Component scripts, colliders, signals and save state are untouched; removing this node restores the greybox look.

const ART_DIR := "res://assets/models/lab/"
const PhotoMaterial := preload("res://scripts/levels/lab_photo_material.gd")
const BARREL := "res://assets/models/props/barrel_03/barrel_03_2k.gltf"

## script file name -> art GLB, glow map {component variable: art node}, optional follows
const CONFIG := {
	"connection_node.gd": {"art": "lab_power_node_a.glb", "glow": {"_orb": "emit_orb", "_ring": "emit_ring"}},
	"junction_box.gd": {"art": "lab_junction_box_a.glb", "glow": {"_lamp": "emit_lamp"}},
	"powered_terminal.gd": {"art": "lab_terminal_power_a.glb", "glow": {"_screen": "emit_screen"}},
	"terminal.gd": {"art": "lab_terminal_power_a.glb", "glow": {"_screen": "emit_screen"}},
	"push_button.gd": {"art": "lab_button_pedestal_a.glb", "glow": {"_top": "emit_cap"}},
	"memory_fragment.gd": {"art": "lab_memory_fragment_a.glb", "glow": {"_gem": "emit_gem"}, "gem": "emit_gem"},
	"checkpoint.gd": {"art": "lab_checkpoint_arch_a.glb", "glow_list": {"_parts": ["emit_arch_post_L", "emit_arch_post_R", "emit_arch_lintel"]}},
	"lever.gd": {"art": "lab_lever_a.glb", "glow": {"_lamp": "emit_lamp"}, "lever": "LeverArm"},
	"door.gd": {"art": "lab_door_slab_a.glb", "glow": {"_strip": "emit_strip"}, "door": "DoorSlab"},
	"robotic_arm.gd": {"art": "lab_robotic_arm_a.glb"},
	# inspect points: art scaled to the greybox footprint (the collider is unchanged); variant 0 crate, 1 console, 2 barrel
	"inspect_point.gd": {"by_variant": {
		0: {"art": "lab_container_a.glb", "fit": Vector3(0.9, 0.7, 0.9)},
		1: {"art": "lab_console_a.glb", "fit": Vector3(0.7, 1.0, 0.5)},
		2: {"path": BARREL, "fit": Vector3(0.7, 0.9, 0.7), "uniform": true}}},
}
## Components that keep their greybox mesh but get a photographic material on the mesh with this base colour.
const RETEXTURE := {
	"moving_platform.gd": {"base_color": Color(0.34, 0.37, 0.41), "photo": "metal_plate", "tint": Color(0.75, 0.8, 0.85), "tile_m": 1.5},
}
const GEM_REST_Y := 1.0  # the greybox gem floats around this height

## One entry per dressed component: {node, mirrors:[{src, dst}], gem, gem_src, lever_arm, door_slab}
var _entries: Array = []


func _ready() -> void:
	name = "LabArtComponents"
	var host := get_parent()
	if host == null:
		return
	# deferred so every component has finished its own _ready (they build their meshes there)
	call_deferred("_dress_all", host)


func _dress_all(host: Node) -> void:
	for node in host.find_children("*", "Node3D", true, false):
		var script := node.get_script() as Script
		if script == null:
			continue
		var key := script.resource_path.get_file()
		if CONFIG.has(key) and node.get_node_or_null("ArtProp") == null:
			_dress(node, CONFIG[key])
		elif RETEXTURE.has(key):
			_retexture(node, RETEXTURE[key])


func _retexture(component: Node3D, cfg: Dictionary) -> void:
	var material := PhotoMaterial.make(cfg["photo"], cfg["tint"], cfg["tile_m"])
	for mesh in component.find_children("*", "MeshInstance3D", true, false):
		var current := (mesh as MeshInstance3D).material_override as StandardMaterial3D
		if current != null and current.albedo_color.is_equal_approx(cfg["base_color"]):
			(mesh as MeshInstance3D).material_override = material


func _dress(component: Node3D, config: Dictionary) -> void:
	var cfg := config
	if config.has("by_variant"):
		cfg = (config["by_variant"] as Dictionary).get(int(component.get("variant")), {})
		if cfg.is_empty():
			return
	var path: String = String(cfg["path"]) if cfg.has("path") else ART_DIR + String(cfg["art"])
	var packed := load(path) as PackedScene
	if packed == null:
		push_warning("LabArtComponents: missing art %s" % path)
		return
	var greybox: Array = component.find_children("*", "MeshInstance3D", true, false)
	var art := packed.instantiate() as Node3D
	art.name = "ArtProp"
	component.add_child(art)
	if cfg.has("fit"):
		_fit(art, cfg["fit"], bool(cfg.get("uniform", false)))
	for mesh in greybox:
		(mesh as MeshInstance3D).layers = 0  # hidden by render layer: components that toggle `visible` themselves cannot bring it back
	var entry := {"node": component, "mirrors": [], "gem": null, "gem_src": null, "lever_arm": null, "pivot": null, "door_slab": null, "slab": null}
	for variable in cfg.get("glow", {}):
		_mirror(entry, component.get(variable), art.find_child(cfg["glow"][variable], true, false))
	for variable in cfg.get("glow_list", {}):
		var sources = component.get(variable)
		var names: Array = cfg["glow_list"][variable]
		if typeof(sources) == TYPE_ARRAY:
			for i in mini(sources.size(), names.size()):
				_mirror(entry, sources[i], art.find_child(names[i], true, false))
	if cfg.has("gem"):
		entry["gem"] = art.find_child(cfg["gem"], true, false)
		entry["gem_src"] = component.get("_gem")
	if cfg.has("lever"):
		entry["lever_arm"] = art.find_child(cfg["lever"], true, false)
		entry["pivot"] = component.get("_pivot")
	if cfg.has("door"):
		entry["door_slab"] = art.find_child(cfg["door"], true, false)
		entry["slab"] = component.get("_slab")
	_entries.append(entry)
	_sync(entry)


## Scales and offsets `art` so its bounds match `size` (footprint of the greybox collider), sitting on the floor.
func _fit(art: Node3D, size: Vector3, uniform: bool) -> void:
	var low := Vector3(1e9, 1e9, 1e9)
	var high := Vector3(-1e9, -1e9, -1e9)
	for m in art.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		var xf := mi.transform
		var parent := mi.get_parent()
		while parent != null and parent != art:
			xf = (parent as Node3D).transform * xf
			parent = parent.get_parent()
		var box := xf * mi.get_aabb()
		low = low.min(box.position)
		high = high.max(box.end)
	var extent := high - low
	if extent.x <= 0.0 or extent.y <= 0.0 or extent.z <= 0.0:
		return
	var s := Vector3(size.x / extent.x, size.y / extent.y, size.z / extent.z)
	if uniform:
		s = Vector3.ONE * minf(minf(s.x, s.z), s.y)
	art.scale = s
	art.position = Vector3(-(low.x + extent.x * 0.5) * s.x, -low.y * s.y, -(low.z + extent.z * 0.5) * s.z)


## Gives the art's emissive part its own material (art materials are shared per asset) and links it to the greybox glow mesh.
func _mirror(entry: Dictionary, src: Variant, dst: Node) -> void:
	if not (src is MeshInstance3D) or not (dst is MeshInstance3D):
		return
	var target := dst as MeshInstance3D
	var base := target.mesh.surface_get_material(0)
	var own: StandardMaterial3D = (base.duplicate() as StandardMaterial3D) if base is StandardMaterial3D else StandardMaterial3D.new()
	own.emission_enabled = true
	target.material_override = own
	(entry["mirrors"] as Array).append({"src": src, "dst": target})


func _process(_delta: float) -> void:
	for entry in _entries:
		_sync(entry)


func _sync(entry: Dictionary) -> void:
	if not is_instance_valid(entry["node"]):
		return
	for pair in entry["mirrors"]:
		var src := pair["src"] as MeshInstance3D
		var dst := pair["dst"] as MeshInstance3D
		if not is_instance_valid(src) or not is_instance_valid(dst):
			continue
		dst.visible = src.visible
		var from := src.material_override as StandardMaterial3D
		var to := dst.material_override as StandardMaterial3D
		if from != null and to != null:
			to.albedo_color = from.albedo_color
			to.emission_enabled = from.emission_enabled
			to.emission = from.emission
			to.emission_energy_multiplier = from.emission_energy_multiplier
	var gem := entry["gem"] as Node3D
	var gem_src := entry["gem_src"] as Node3D
	if gem != null and is_instance_valid(gem_src):
		gem.visible = gem_src.visible
		gem.position.y = GEM_REST_Y + (gem_src.position.y - GEM_REST_Y)
		gem.rotation.y = gem_src.rotation.y
	var arm := entry["lever_arm"] as Node3D
	var pivot := entry["pivot"] as Node3D
	if arm != null and is_instance_valid(pivot):
		arm.rotation_degrees.z = pivot.rotation_degrees.z
	var door := entry["door_slab"] as Node3D
	var slab := entry["slab"] as Node3D
	if door != null and is_instance_valid(slab):
		door.position.z = slab.position.z
