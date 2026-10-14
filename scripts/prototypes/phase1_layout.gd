extends RefCounted
## Data and validation for the Phase 1 room complex: six rooms, four levels, four fixed staircases.
## Pure data (no nodes, no physics). The greybox builder and the layout test both read it.
## Plan coordinates: x west-east, z north (negative) to south (positive); y is the floor height in metres.

const WALL_HEIGHT := 4.5
const MAX_STAIR_SLOPE_DEG := 30.0
const MIN_OPENING := 2.0

const ROOMS := {
	"entry": {"name": "Vestíbulo de acceso", "x0": 0.0, "x1": 10.0, "z0": -3.0, "z1": 5.0, "y": 0.0, "spawn": Vector3(2.0, 0.2, 1.0)},
	"test_hall": {"name": "Sala de ensayo", "x0": 10.0, "x1": 26.0, "z0": -12.0, "z1": 8.0, "y": 0.0, "spawn": Vector3(13.0, 0.2, 5.0), "wall": "bulkhead", "side_h": {"north": 3.0}},
	"pit": {"name": "Foso de servicio", "x0": 10.0, "x1": 26.0, "z0": 14.0, "z1": 24.0, "y": -2.0, "spawn": Vector3(12.0, -1.8, 16.0), "wall": "bulkhead"},
	"pump": {"name": "Sala de bombas", "x0": 32.0, "x1": 44.0, "z0": -6.0, "z1": 6.0, "y": 1.5, "spawn": Vector3(34.0, 1.7, 0.0)},
	"catwalk": {"name": "Pasarela superior", "x0": 8.0, "x1": 44.0, "z0": -16.0, "z1": -12.0, "y": 3.0, "spawn": Vector3(40.0, 3.2, -14.0), "wall": "bulkhead", "floor": "grate", "rail_sides": ["south"]},
	"cabin": {"name": "Cabina de archivo", "x0": 0.0, "x1": 8.0, "z0": -18.0, "z1": -10.0, "y": 3.0, "spawn": Vector3(4.0, 3.2, -14.0)},
}

## axis = run direction; a0/a1 = coordinates of both ends along that axis; c0/c1 = lateral extent; y0/y1 = heights at a0/a1.
const STAIRS := [
	{"id": "S1", "from": "test_hall", "to": "pit", "axis": "z", "c0": 12.0, "c1": 14.0, "a0": 8.0, "a1": 14.0, "y0": 0.0, "y1": -2.0},
	{"id": "S2", "from": "test_hall", "to": "pump", "axis": "x", "c0": -1.5, "c1": 1.5, "a0": 26.0, "a1": 32.0, "y0": 0.0, "y1": 1.5},
	{"id": "S3", "from": "catwalk", "to": "pump", "axis": "z", "c0": 36.0, "c1": 38.0, "a0": -12.0, "a1": -6.0, "y0": 3.0, "y1": 1.5},
	{"id": "S4", "from": "cabin", "to": "entry", "axis": "z", "c0": 1.0, "c1": 3.0, "a0": -10.0, "a1": -3.0, "y0": 3.0, "y1": 0.0},
]

## Same-level openings. axis = normal of the wall plane; at = its coordinate; c0/c1 = opening along the wall.
## The owner builds the shared wall; the other room skips that side.
const DOORS := [
	{"owner": "test_hall", "other": "entry", "axis": "x", "at": 10.0, "c0": -1.5, "c1": 1.5},
	{"owner": "cabin", "other": "catwalk", "axis": "x", "at": 8.0, "c0": -15.0, "c1": -13.0},
]

## Future clue and control positions (signs only in this build).
const POSITIONS := {
	"archive": {"label": "ARCHIVE (record terminal)", "at": Vector3(4.0, 3.0, -15.0)},
	"selector": {"label": "SELECTOR (control position)", "at": Vector3(14.0, 3.0, -14.0)},
	"isolator": {"label": "ISOLATOR (control position)", "at": Vector3(20.0, 3.0, -14.0)},
	"indicators": {"label": "INDICATORS (readable from here)", "at": Vector3(17.0, 3.0, -14.0)},
	"schematic": {"label": "SCHEMATIC (clue position)", "at": Vector3(22.0, -2.0, 19.0)},
	"bridge": {"label": "TAMPERED BRIDGE (clue position)", "at": Vector3(14.0, -2.0, 18.0)},
	"maintenance": {"label": "MAINTENANCE SWITCH (control position)", "at": Vector3(23.0, -2.0, 22.0)},
	"lift_slot": {"label": "LIFT SLOT (not installed)", "at": Vector3(38.0, 1.5, 4.0)},
}


static func room_rect(room: Dictionary) -> Rect2:
	return Rect2(room["x0"], room["z0"], float(room["x1"]) - float(room["x0"]), float(room["z1"]) - float(room["z0"]))


static func stair_rect(stair: Dictionary) -> Rect2:
	var length := float(stair["a1"]) - float(stair["a0"])
	var width := float(stair["c1"]) - float(stair["c0"])
	if stair["axis"] == "z":
		return Rect2(stair["c0"], stair["a0"], width, length)
	return Rect2(stair["a0"], stair["c0"], length, width)


static func stair_slope_deg(stair: Dictionary) -> float:
	return rad_to_deg(atan2(absf(float(stair["y1"]) - float(stair["y0"])), absf(float(stair["a1"]) - float(stair["a0"]))))


static func room_at(point: Vector3) -> String:
	for id in ROOMS:
		var r: Dictionary = ROOMS[id]
		if point.x >= float(r["x0"]) and point.x <= float(r["x1"]) and point.z >= float(r["z0"]) and point.z <= float(r["z1"]) and absf(point.y - float(r["y"])) < 2.5:
			return id
	return ""


static func _side_of(room: Dictionary, axis: String, value: float) -> String:
	if axis == "z":
		if is_equal_approx(value, float(room["z0"])):
			return "north"
		if is_equal_approx(value, float(room["z1"])):
			return "south"
	elif axis == "x":
		if is_equal_approx(value, float(room["x0"])):
			return "west"
		if is_equal_approx(value, float(room["x1"])):
			return "east"
	return ""


## Wall openings of a room per side, as [lo, hi] pairs along the wall.
static func openings(room_id: String) -> Dictionary:
	var out := {"north": [], "south": [], "west": [], "east": []}
	var r: Dictionary = ROOMS[room_id]
	for s in STAIRS:
		if s["from"] == room_id:
			var side_from := _side_of(r, s["axis"], float(s["a0"]))
			if side_from != "":
				out[side_from].append([s["c0"], s["c1"]])
		if s["to"] == room_id:
			var side_to := _side_of(r, s["axis"], float(s["a1"]))
			if side_to != "":
				out[side_to].append([s["c0"], s["c1"]])
	for d in DOORS:
		if d["owner"] == room_id or d["other"] == room_id:
			var side_door := _side_of(r, d["axis"], float(d["at"]))
			if side_door != "":
				out[side_door].append([d["c0"], d["c1"]])
	return out


## Sides whose wall is built by the neighbouring room that owns the shared boundary.
static func skipped_sides(room_id: String) -> Array:
	var out: Array = []
	var r: Dictionary = ROOMS[room_id]
	for d in DOORS:
		if d["other"] == room_id:
			var side := _side_of(r, d["axis"], float(d["at"]))
			if side != "":
				out.append(side)
	return out


static func reachable_from(start: String, skip_stair: String = "") -> Array:
	var adjacency := {}
	for id in ROOMS:
		adjacency[id] = []
	for s in STAIRS:
		if s["id"] == skip_stair:
			continue
		adjacency[s["from"]].append(s["to"])
		adjacency[s["to"]].append(s["from"])
	for d in DOORS:
		adjacency[d["owner"]].append(d["other"])
		adjacency[d["other"]].append(d["owner"])
	var seen: Array = [start]
	var queue: Array = [start]
	while not queue.is_empty():
		var current: String = queue.pop_back()
		for n in adjacency[current]:
			if not seen.has(n):
				seen.append(n)
				queue.append(n)
	return seen


static func _lateral_inside(room: Dictionary, stair: Dictionary) -> bool:
	var lo := float(room["x0"]) if stair["axis"] == "z" else float(room["z0"])
	var hi := float(room["x1"]) if stair["axis"] == "z" else float(room["z1"])
	return lo <= float(stair["c0"]) and float(stair["c1"]) <= hi


## Every consistency problem of the layout (empty array = valid).
static func problems() -> Array:
	var out: Array = []
	var rects := {}
	for id in ROOMS:
		rects[id] = room_rect(ROOMS[id])
	for s in STAIRS:
		rects[s["id"]] = stair_rect(s)
	var keys := rects.keys()
	for i in keys.size():
		for j in range(i + 1, keys.size()):
			if (rects[keys[i]] as Rect2).intersects(rects[keys[j]] as Rect2):
				out.append("plan overlap: %s / %s" % [keys[i], keys[j]])
	for s in STAIRS:
		var f: Dictionary = ROOMS[s["from"]]
		var t: Dictionary = ROOMS[s["to"]]
		if not is_equal_approx(float(f["y"]), float(s["y0"])) or not is_equal_approx(float(t["y"]), float(s["y1"])):
			out.append("%s: end heights do not match its rooms" % s["id"])
		if _side_of(f, s["axis"], float(s["a0"])) == "" or _side_of(t, s["axis"], float(s["a1"])) == "":
			out.append("%s: ends are not on room boundaries" % s["id"])
		if not _lateral_inside(f, s) or not _lateral_inside(t, s):
			out.append("%s: not inside the room openings" % s["id"])
		if stair_slope_deg(s) > MAX_STAIR_SLOPE_DEG:
			out.append("%s: too steep" % s["id"])
		if float(s["c1"]) - float(s["c0"]) < MIN_OPENING - 0.0001:
			out.append("%s: narrower than %.1f m" % [s["id"], MIN_OPENING])
	for d in DOORS:
		var o: Dictionary = ROOMS[d["owner"]]
		var p: Dictionary = ROOMS[d["other"]]
		if not is_equal_approx(float(o["y"]), float(p["y"])):
			out.append("door %s/%s joins different levels" % [d["owner"], d["other"]])
		if _side_of(o, d["axis"], float(d["at"])) == "" or _side_of(p, d["axis"], float(d["at"])) == "":
			out.append("door %s/%s is not on both room boundaries" % [d["owner"], d["other"]])
		if float(d["c1"]) - float(d["c0"]) < MIN_OPENING - 0.0001:
			out.append("door %s/%s narrower than %.1f m" % [d["owner"], d["other"], MIN_OPENING])
		for room in [o, p]:
			var lo := float(room["z0"]) if d["axis"] == "x" else float(room["x0"])
			var hi := float(room["z1"]) if d["axis"] == "x" else float(room["x1"])
			if float(d["c0"]) < lo or float(d["c1"]) > hi:
				out.append("door %s/%s leaves the room wall" % [d["owner"], d["other"]])
	if reachable_from("entry").size() != ROOMS.size():
		out.append("some rooms are unreachable from the entry")
	if not reachable_from("entry", "S4").has("cabin"):
		out.append("the locked shortcut gates progress to the cabin")
	return out
