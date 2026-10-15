extends RefCounted
## Mesh library for the environment art layer.
## - Kit pieces from assets/models/env/station_kit.glb (tools/blender/build_station_kit.py): their material names are keys of
##   the facility palette, so they get the same world-space station materials as the walls around them.
## - Prepared CC0 props from assets/models/props/ph (tools/blender/prepare_ph_props.py): they keep their own textured materials.
## Entries are {"mesh": Mesh, "materials": Array[Material], "aabb": AABB}; meshes are shared, never duplicated.

const KIT_PATH := "res://assets/models/env/station_kit.glb"
const PROP_DIR := "res://assets/models/props/ph/"

var mats = null
var _kit: Dictionary = {}
var _props: Dictionary = {}


func _init(materials) -> void:
	mats = materials


func kit(piece: String) -> Dictionary:
	if _kit.is_empty():
		_load_kit()
	return _kit.get(piece, {})


func prop(asset: String) -> Dictionary:
	if not _props.has(asset):
		_props[asset] = _load_prop(asset)
	return _props[asset]


func _load_kit() -> void:
	if not ResourceLoader.exists(KIT_PATH):
		push_warning("KitLibrary: %s is missing" % KIT_PATH)
		return
	var scene := (load(KIT_PATH) as PackedScene).instantiate()
	for node in scene.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var materials: Array = []
		for s in mi.mesh.get_surface_count():
			var imported := mi.mesh.surface_get_material(s)
			var key := imported.resource_name if imported != null else "graphite"
			materials.append(mats.get_material(key))
		_kit[String(mi.name)] = {"mesh": mi.mesh, "materials": materials, "aabb": mi.mesh.get_aabb()}
	scene.free()


func _load_prop(asset: String) -> Dictionary:
	var path := PROP_DIR + asset + ".glb"
	if not ResourceLoader.exists(path):
		push_warning("KitLibrary: %s is missing" % path)
		return {}
	var scene := (load(path) as PackedScene).instantiate()
	var found := scene.find_children("*", "MeshInstance3D", true, false)
	var out: Dictionary = {}
	if not found.is_empty():
		var mi := found[0] as MeshInstance3D
		var materials: Array = []
		for s in mi.mesh.get_surface_count():
			materials.append(mi.mesh.surface_get_material(s))
		out = {"mesh": mi.mesh, "materials": materials, "aabb": mi.mesh.get_aabb()}
	scene.free()
	return out
